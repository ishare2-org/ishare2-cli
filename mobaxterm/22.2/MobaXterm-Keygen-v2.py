# /usr/bin/env python3

'''
Author: Double Sine
License: GPLv3
Last modified: 10-Dec-2022
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


variant_base64_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

variant_base64_dict = {
    i: variant_base64_table[i] for i in range(len(variant_base64_table))
}

variant_base64_reverse_dict = {
    variant_base64_table[i]: i for i in range(len(variant_base64_table))
}


def variant_base64_encode(bs: bytes):
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


def variant_base64_decode(s: str):
    result = b''
    blocks_count, left_bytes = divmod(len(s), 4)

    for i in range(blocks_count):
        block = variant_base64_reverse_dict[s[4 * i]]
        block += variant_base64_reverse_dict[s[4 * i + 1]] << 6
        block += variant_base64_reverse_dict[s[4 * i + 2]] << 12
        block += variant_base64_reverse_dict[s[4 * i + 3]] << 18
        result += block.to_bytes(3, 'little')

    if left_bytes == 0:
        return result
    elif left_bytes == 2:
        block = variant_base64_reverse_dict[s[4 * blocks_count]]
        block += variant_base64_reverse_dict[s[4 * blocks_count + 1]] << 6
        result += block.to_bytes(1, 'little')
        return result
    elif left_bytes == 3:
        block = variant_base64_reverse_dict[s[4 * blocks_count]]
        block += variant_base64_reverse_dict[s[4 * blocks_count + 1]] << 6
        block += variant_base64_reverse_dict[s[4 * blocks_count + 2]] << 12
        result += block.to_bytes(2, 'little')
        return result
    else:
        raise ValueError('Invalid encoding.')


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


class LicenseType:
    Professional = 1
    Educational = 3
    Personal = 4


def generate_license(license_type: LicenseType, count: int, username: str, major_version: int, minor_version: int):
    assert (count >= 0)
    LicenseString = '%d#%s|%d%d#%d#%d3%d6%d#%d#%d#%d#' % (
        license_type,
        username, major_version, minor_version,
        count,
        major_version, minor_version, minor_version,
        0,    # Unknown
        # No Games flag. 0 means "NoGames = false". But it does not work.
        0,
        0)    # No Plugins flag. 0 means "NoPlugins = false". But it does not work.

    encoded_license_string = variant_base64_encode(
        encrypt_bytes(0x787, LicenseString.encode())).decode()

    with zipfile.ZipFile(os.path.join(os.getcwd(), 'Custom.mxtpro'), 'w') as f:
        f.writestr('Pro.key', data=encoded_license_string)


def help():
    print("Usage:")
    print("  MobaXterm-Keygen.py <username> <version>\n")
    print("  <username>:  The name MobaXterm will be licensed to")
    print("  <version> :  MobaXterm version. Example: 22.2")
    print("\nExample: python MobaXterm-Keygen.py admin 22.2")


def move_license_to(dst):
    src = os.path.join(os.getcwd(), 'Custom.mxtpro')

    try:
        shutil.move(src, dst)
    except Exception as e:
        exit(1)


def start_mobaxterm(executable_path):
    print("[*] Success!")
    print("[*] Opening MobaXterm...")
    os.startfile(executable_path)


def main():
    number_of_args = len(sys.argv)

    if number_of_args != 3:
        if number_of_args == 1:
            print(str(number_of_args) + " arg was provided but 3 are required")
        else:
            print(str(number_of_args) + " args were provided but 3 are required")
        help()
        exit(1)

    response = run_as_admin()
    if response is False:  # False means user selected either No or has closed the window
        exit(1)

    major_version, minor_version = sys.argv[2].split('.')[0:2]
    major_version = int(major_version)
    minor_version = int(minor_version)

    generate_license(
        license_type=LicenseType.Professional,
        count=1,
        username=sys.argv[1],
        major_version=major_version,
        minor_version=minor_version
    )

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
            break

    if executable_exists:
        dst = executable_path[:-13] + "Custom.mxtpro"
        move_license_to(dst)
        start_mobaxterm(executable_path)
    else:
        print("[*] File Custom.mxtpro was generated at", os.getcwd())
        print(
            "[*] Move this file to MobaXterm\'s installation path and then execute MobaXterm.exe")


if __name__ == '__main__':
    main()
