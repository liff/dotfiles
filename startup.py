import atexit
import os
import readline

xdg_data_home = os.getenv('XDG_DATA_HOME')
if xdg_data_home is None:
    data_dir = os.path.join(os.path.expanduser("~"), "local", "share", "python")
else:
    data_dir = os.path.join(xdg_data_home, "python")

os.makedirs(data_dir, exist_ok = True)

history_file = os.path.join(data_dir, 'history')

try:
    readline.read_history_file(history_file)
except FileNotFoundError:
    pass

atexit.register(readline.write_history_file, history_file)

