# /usr/bin/env python3

'''
Author: Double Sine
License: GPLv3
Last modified: 11-Feb-2023
'''

import ctypes
import os
import os.path
import shutil
import sys
import zipfile


def run_as_admin(argv=None):
    shell32 = ctypes.windll.shell32

    if argv is None and shell32.IsUserAnAdmin():
        return True  # When user is an admin

    if argv is None:
        argv = sys.argv

    if sys.version_info[0] >= 3:  # Check Python 3 is being used
        unicode = str

    if hasattr(sys, '_MEIPASS'):
        # Support pyinstaller wrapped program
        arguments = map(unicode, argv[1:])
    else:
        arguments = map(unicode, argv)

    argument_line = u' '.join(arguments)
    executable = unicode(sys.executable)

    response = shell32.ShellExecuteW(
        None,
        u"runas",
        executable,
        argument_line,
        None,
        1
    )

    if response <= 32:
        return False  # When user says No (to the window)
    return None  # When user says Yes (to the window)


def variant_base64_encode(bs: bytes, variant_base64_dict):
    result = b''
    blocks_count, left_bytes = divmod(len(bs), 3)

    for i in range(blocks_count):
        coding_int = int.from_bytes(bs[3 * i:3 * i + 3], 'little')
        block = variant_base64_dict[coding_int & 0x3f]
        block += variant_base64_dict[(coding_int >> 6) & 0x3f]
        block += variant_base64_dict[(coding_int >> 12) & 0x3f]
        block += variant_base64_dict[(coding_int >> 18) & 0x3f]
        result += block.encode()

    if left_bytes == 0:
        return result
    elif left_bytes == 1:
        coding_int = int.from_bytes(bs[3 * blocks_count:], 'little')
        block = variant_base64_dict[coding_int & 0x3f]
        block += variant_base64_dict[(coding_int >> 6) & 0x3f]
        result += block.encode()
        return result
    else:
        coding_int = int.from_bytes(bs[3 * blocks_count:], 'little')
        block = variant_base64_dict[coding_int & 0x3f]
        block += variant_base64_dict[(coding_int >> 6) & 0x3f]
        block += variant_base64_dict[(coding_int >> 12) & 0x3f]
        result += block.encode()
        return result


def encrypt_bytes(key: int, bs: bytes):
    result = bytearray()
    for i in range(len(bs)):
        result.append(bs[i] ^ ((key >> 8) & 0xff))
        key = result[-1] & key | 0x482D
    return bytes(result)


def decrypt_bytes(key: int, bs: bytes):
    result = bytearray()
    for i in range(len(bs)):
        result.append(bs[i] ^ ((key >> 8) & 0xff))
        key = bs[i] & key | 0x482D
    return bytes(result)


def generate_license(license_type, count: int, username: str, major_version: int, minor_version: int, variant_base64_dict):
    assert (count >= 0)
    LicenseString = '%d#%s|%d%d#%d#%d3%d6%d#%d#%d#%d#' % (
        license_type,
        username,
        major_version,
        minor_version,
        count,
        major_version,
        minor_version,
        minor_version,
        0,  # Unknown
        # No Games flag. 0 means "NoGames = false". But it does not work.
        0,
        0)  # No Plugins flag. 0 means "NoPlugins = false". But it does not work.

    encoded_license_string = variant_base64_encode(
        encrypt_bytes(0x787, LicenseString.encode()), variant_base64_dict).decode()

    with zipfile.ZipFile(os.path.join(os.getcwd(), 'Custom.mxtpro'), 'w') as f:
        f.writestr('Pro.key', data=encoded_license_string)


def move_license_to(dst):
    src = os.path.join(os.getcwd(), 'Custom.mxtpro')

    try:
        shutil.move(src, dst)
    except Exception:
        exit(1)


def start_mobaxterm(executable_path):
    print("[*] Success!")
    print("[*] Opening MobaXterm...")
    os.startfile(executable_path)


def config(sys):
    number_of_args = len(sys.argv)

    if number_of_args == 3:
        username = sys.argv[1],
        username = ''.join(username)
        major_version, minor_version = sys.argv[2].split('.')[0:2]
        major_version = int(major_version)
        minor_version = int(minor_version)
    else:
        username = "admin"
        mobaxterm_version = "23.0"
        major_version, minor_version = mobaxterm_version.split('.')[0:2]
        major_version = int(major_version)
        minor_version = int(minor_version)

    return username, major_version, minor_version


def create_base64_dict():
    variant_base64_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

    variant_base64_dict = {
        i: variant_base64_table[i] for i in range(len(variant_base64_table))
    }

    return variant_base64_dict


def last_steps():
    possible_moba_exe_locations = [
        "C:/Program Files (x86)/Mobatek/MobaXterm/MobaXterm.exe",
        "D:/Program Files (x86)/Mobatek/MobaXterm/MobaXterm.exe",
        "E:/Program Files (x86)/Mobatek/MobaXterm/MobaXterm.exe"
    ]

    executable_exists = False
    for path in possible_moba_exe_locations:
        if os.path.isfile(path):
            executable_path = path
            executable_exists = True
            break  # Exit for loop at the first match. Maybe, MobaXterm.exe is located in more than one path

    if executable_exists:
        dst = executable_path[: -13] + "Custom.mxtpro"
        move_license_to(dst)
        start_mobaxterm(executable_path)
    else:
        print("[*] File Custom.mxtpro was generated at", os.getcwd())
        print("[*] Move Custom.mxtpro file to MobaXterm\'s installation path and then execute MobaXterm.exe")


def main():
    username, major_version, minor_version = config(sys)

    response = run_as_admin()
    if response is False:  # False means user has choiced either "No" when prompted or has closed the window using the close button
        exit(1)

    variant_base64_dict = create_base64_dict()

    generate_license(
        license_type=1,  # 1 for Professional, 3 for Educational and 4 for Personal
        count=1,
        username=username,
        major_version=major_version,
        minor_version=minor_version,
        variant_base64_dict=variant_base64_dict
    )

    last_steps()


if __name__ == '__main__':
    main()
