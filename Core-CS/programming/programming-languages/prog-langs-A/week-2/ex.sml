signature NatSig = 
	sig
		type natural
		exception BadNat
		val MakeNatural : int -> natural
		val add : natural * natural -> natural
		val toString : natural -> string
	end

structure Naturals :> NatSig =
	struct
		datatype natural = Nat of int
		exception BadNat
		
		fun MakeNatural x =
			if x < 0
			then raise BadNat (*Naturals can't be negative*)
			else Nat x
		
		fun add (x, y) =
			case (x, y) of
			    (Nat x', Nat y') => Nat(x' + y')
		
		fun toString x =
			case x of
				Nat x' => (Int.toString x')
	end
