import readline

print("\n".join([ f"{a}\t{b}" for a,b in { i:str(readline.get_history_item(i)) for i in range(0, readline.get_current_history_length()) }.items() ]))
