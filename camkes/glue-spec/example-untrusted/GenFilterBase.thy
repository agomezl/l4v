(*
 * Copyright 2014, NICTA
 *
 * This software may be distributed and modified according to the terms of
 * the GNU General Public License version 2. Note that NO WARRANTY is provided.
 * See "LICENSE_GPLv2.txt" for details.
 *
 * @TAG(NICTA_GPL)
 *)
chapter {* \label{h:filter}Example -- System Level Reasoning *}

(*<*)
(* THIS FILE IS AUTOMATICALLY GENERATED. YOUR EDITS WILL BE OVERWRITTEN. *)
theory GenFilterBase
imports "../Types" "../Abbreviations" "../Connector"
begin
(*>*)

text {*
  This section provides an example of a more detailed \camkes system and reasoning
  about a system level property of such a system. The example system is
  described by the following specification:

  \camkeslisting{filter.camkes}

  It consists of an instance, @{term client}, that reads values out of a
  key-value
  store in the instance, @{term store}. Its access is mediated by the
  instance @{term filter} that prevents it reading the value ``baz'' associated
  with the key ``secret''.

  \begin{figure}[h]
    \begin{center}
      \includegraphics[width=300px]{imgs/filter}
    \end{center}
    \caption{\label{fig:filter}Example filter system}
  \end{figure}

  The generated types and definitions are omitted, but they are similar to
  those described in \autoref{h:procbase}.
*}

(*<*)
(* Connections *)
datatype channel
  = two
  | one

(* Component instances *)
datatype inst
  = store
  | client
  | filter

(* Store's interfaces *)
datatype Store_channel
  = Store_l

definition
  Recv_Store_l :: "(Store_channel \<Rightarrow> channel) \<Rightarrow>
    ('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow> (channel, 'cs) comp \<Rightarrow>
    ('cs local_state \<Rightarrow> string) \<Rightarrow> (channel, 'cs) comp"
where
  "Recv_Store_l ch get_value\<^sub>E Store_l_get_value get_value_return\<^sub>P \<equiv>
    (Response (\<lambda>q s. case q_data q of Call n xs \<Rightarrow>
      (if n = 0 then {(get_value\<^sub>E s (case xs ! 0 of String v \<Rightarrow> v),
      \<lparr>a_channel = ch Store_l, a_data = Void\<rparr>)} else {}) | _ \<Rightarrow> {}) ;;
     Store_l_get_value ;;
     Request (\<lambda>s. {\<lparr>q_channel = ch Store_l,
      q_data = Return (String (get_value_return\<^sub>P s) # [])\<rparr>}) discard)"

(* Client's interfaces *)
datatype Client_channel
  = Client_l

definition
  Call_Client_l_get_value :: "(Client_channel \<Rightarrow> channel) \<Rightarrow>
    ('cs local_state \<Rightarrow> string) \<Rightarrow>
    ('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow> (channel, 'cs) comp"
where
  "Call_Client_l_get_value ch id\<^sub>P embed_data \<equiv>
    Request (\<lambda>s. {\<lparr>q_channel = ch Client_l,
      q_data = Call 0 (String (id\<^sub>P s) # [])\<rparr>}) discard ;;
    Response (\<lambda>q s. case q_data q of Return xs \<Rightarrow>
      {(embed_data s (case hd xs of String v \<Rightarrow> v),
      \<lparr>a_channel = ch Client_l, a_data = Void\<rparr>)} | _ \<Rightarrow> {})"

(* Filter's interfaces *)
datatype Filter_channel
  = Filter_external
  | Filter_backing

definition
  Call_Filter_backing_get_value :: "(Filter_channel \<Rightarrow> channel) \<Rightarrow>
    ('cs local_state \<Rightarrow> string) \<Rightarrow>
    ('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow> (channel, 'cs) comp"
where
  "Call_Filter_backing_get_value ch id\<^sub>P embed_data \<equiv>
    Request (\<lambda>s. {\<lparr>q_channel = ch Filter_backing,
      q_data = Call 0 (String (id\<^sub>P s) # [])\<rparr>}) discard ;;
    Response (\<lambda>q s. case q_data q of Return xs \<Rightarrow>
      {(embed_data s (case hd xs of String v \<Rightarrow> v),
      \<lparr>a_channel = ch Filter_backing, a_data = Void\<rparr>)} | _ \<Rightarrow> {})"

definition
  Recv_Filter_external :: "(Filter_channel \<Rightarrow> channel) \<Rightarrow>
    ('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow>
    (channel, 'cs) comp \<Rightarrow> ('cs local_state \<Rightarrow> string) \<Rightarrow> (channel, 'cs) comp"
where
  "Recv_Filter_external ch get_value\<^sub>E Filter_external_get_value get_value_return\<^sub>P \<equiv>
    (Response (\<lambda>q s. case q_data q of Call n xs \<Rightarrow>
      (if n = 0 then {(get_value\<^sub>E s (case xs ! 0 of String v \<Rightarrow> v),
      \<lparr>a_channel = ch Filter_external, a_data = Void\<rparr>)} else {}) | _ \<Rightarrow> {}) ;;
     Filter_external_get_value ;;
     Request (\<lambda>s. {\<lparr>q_channel = ch Filter_external,
       q_data = Return (String (get_value_return\<^sub>P s) # [])\<rparr>}) discard)"

(* Component instantiations *)
definition
  Recv_store_l :: "('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow>
    (channel, 'cs) comp \<Rightarrow> ('cs local_state \<Rightarrow> string) \<Rightarrow> (channel, 'cs) comp"
where
  "Recv_store_l \<equiv> Recv_Store_l (\<lambda>c. case c of Store_l \<Rightarrow> two)"

definition
  Call_client_l_get_value :: "('cs local_state \<Rightarrow> string) \<Rightarrow>
    ('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow> (channel, 'cs) comp"
where
  "Call_client_l_get_value \<equiv>
    Call_Client_l_get_value (\<lambda>c. case c of Client_l \<Rightarrow> one)"

definition
  Call_filter_backing_get_value :: "('cs local_state \<Rightarrow> string) \<Rightarrow>
    ('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow> (channel, 'cs) comp"
where
  "Call_filter_backing_get_value \<equiv>
    Call_Filter_backing_get_value (\<lambda>c. case c of Filter_backing \<Rightarrow> two
                                               | Filter_external \<Rightarrow> one)"

definition
  Recv_filter_external :: "('cs local_state \<Rightarrow> string \<Rightarrow> 'cs local_state) \<Rightarrow>
    (channel, 'cs) comp \<Rightarrow> ('cs local_state \<Rightarrow> string) \<Rightarrow>
    (channel, 'cs) comp"
where
  "Recv_filter_external \<equiv>
    Recv_Filter_external (\<lambda>c. case c of Filter_backing \<Rightarrow> two
                                      | Filter_external \<Rightarrow> one)"

end
(*>*)
