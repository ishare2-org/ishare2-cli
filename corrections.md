# Name corrections for images

## Corrections for IOL images

```bash
function corrections_for_iol_images() {
    NAME=$1

    if [[ $NAME = "L2-Adventerprisek9-ms.nov3_2015_high_iron.bin" ]]; then
        NAME="i86bi_linux_l2-L2-Adventerprisek9-ms.nov3_2015_high_iron.bin"

        FILE="$YML_DIR"i86bi_linux_l2.yml
        if ! [[ -e $FILE ]]; then
            wget -O "$FILE" "$URL_I86BI_LINUX_L2_YML" >/dev/null 2>&1
        fi
    fi

    if [[ $NAME = "L3-ADVENTERPRISEK9-M-15.4-2T.bin" ]]; then
        NAME="i86bi_linux_l3-L3-ADVENTERPRISEK9-M-15.4-2T.bin"

        FILE="$YML_DIR"i86bi_linux_l3.yml
        if ! [[ -e $FILE ]]; then
            wget -O "$FILE" "$URL_I86BI_LINUX_L3_YML" >/dev/null 2>&1
        fi
    fi
}
```

```bash
function corrections_for_bin_images_in_lab_function() {
    BIN_NAME=$1
    LAB_PATH=$2

    if [[ $BIN_NAME = "i86_Linux-L2-Adventerpisek9-mx.SSA.high_iron_20190423.bin" ]]; then
        OLD_FILENAME="i86_Linux-L2-Adventerpisek9-mx.SSA.high_iron_20190423.bin"
        NEW_FILENAME="i86bi_linux_l2-adventerprisek9-ms.SSA.high_iron_20190423.bin"
        # Bad spelling: 4 errors
        # 1) i86 should be i86bi (bi is missing)
        # 2) Adventerpisek9 should be Adventerprisek9 (r letter is missing)
        # 3) i86_Linux should be i86bi_linux_l2 (L in Linux should be in lowercase, "bi" missing case and change template)
        # 4) -mx should be -ms (not mx but ms)

        BIN_NAME=$NEW_FILENAME
        echo -e "\nImage filename changed from:\n$OLD_FILENAME"
        echo -e "to\n$NEW_FILENAME\n"

        echo "Changing the filename image inside .unl lab file"
        sed -i -e 's/'$OLD_FILENAME'/'$NEW_FILENAME'/g' "$LAB_PATH"
        echo -e "Changing: OK\n"
    fi

    if [[ $BIN_NAME = "L3-ADVENTERPRISEK9-M-15.4-2T.bin" ]]; then
        OLD_FILENAME="L3-ADVENTERPRISEK9-M-15.4-2T.bin"
        NEW_FILENAME="i86bi_linux_l3-L3-ADVENTERPRISEK9-M-15.4-2T.bin"
        # Bad spelling: 1 error
        # 1) L3 is not a yml valid template (There is not a L3.yml available)
        # So, filename must be i86bi_linux_l3 (for i86bi_linux_l3.yml)

        # BIN_NAME="L3-ADVENTERPRISEK9-M-15.4-2T.bin" # This is the old filename to download it in this case
        # echo -e "\nImage filename changed from:\n$OLD_FILENAME"
        # echo -e "to\n$NEW_FILENAME\n"

        echo "Changing the filename image inside .unl lab file"
        sed -i -e 's/'$OLD_FILENAME'/'$NEW_FILENAME'/g' "$LAB_PATH"
        echo -e "Changing: OK"
    fi
}
```

## Corrections for QEMU images

```bash
function corrections_for_qemu_images_in_lab_function() {
    QEMU_NAME=$1

    if [[ $QEMU_NAME = "huaweicx-V800R011" ]]; then QEMU_NAME="cx"; fi
    if [[ $QEMU_NAME = "huaweine40e-ne40e" ]]; then QEMU_NAME="ne40e"; fi
    if [[ $QEMU_NAME = "huaweine5ke-ne5000e" ]]; then QEMU_NAME="ne5000e"; fi
    if [[ $QEMU_NAME = "huaweine9k-ne9000" ]]; then QEMU_NAME="ne9000"; fi
    if [[ $QEMU_NAME = "huaweice6800-ce6800" ]]; then QEMU_NAME="ce6800"; fi
    if [[ $QEMU_NAME = "huaweice12800-ce12800" ]]; then QEMU_NAME="ce12800"; fi
    if [[ $QEMU_NAME = "cips-7.0.8" ]]; then QEMU_NAME="vIPS-7.0.8"; fi
    if [[ $QEMU_NAME = "catalyst8000v-17.07.01a" ]]; then QEMU_NAME="c8000v-17.07.01a"; fi
    if [[ $QEMU_NAME = "linux-kali2020-epiol" ]]; then QEMU_NAME="kali-2020-epiol"; fi
}
```

```bash
function corrections_for_qemu_images() {
    # Delete ,,, characters (if present) at the end of the FILE6LINK variable (6th element to download)
    if [[ "${FILE6LINK: -4}" == *",,,"* ]]; then FILE6LINK=${FILE6LINK::-4}; fi
    if [[ $FOLDERNAME = "cx" ]]; then FOLDERNAME="huaweicx-V800R011"; fi
    if [[ $FOLDERNAME = "ne40e" ]]; then FOLDERNAME="huaweine40e-ne40e"; fi
    if [[ $FOLDERNAME = "ne5000e" ]]; then FOLDERNAME="huaweine5ke-ne5000e"; fi
    if [[ $FOLDERNAME = "ne9000" ]]; then FOLDERNAME="huaweine9k-ne9000"; fi
    if [[ $FOLDERNAME = "ce6800" ]]; then FOLDERNAME="huaweice6800-ce6800"; fi
    if [[ $FOLDERNAME = "ce12800" ]]; then FOLDERNAME="huaweice12800-ce12800"; fi
    if [[ $FOLDERNAME = "vIPS-7.0.8" ]]; then FOLDERNAME="cips-7.0.8"; fi
    if [[ $FOLDERNAME = "c8000v-17.07.01a" ]]; then FOLDERNAME="catalyst8000v-17.07.01a"; fi
    if [[ $FOLDERNAME = "kali-2020-epiol" ]]; then FOLDERNAME="linux-kali2020-epiol"; fi
}
```

## Corrections for Dynamips images

```bash
function corrections_for_dynamips_images() {
    NAME=$1

    SUBSTRING="c2600"
    if [[ "$NAME" == *"$SUBSTRING"* ]]; then
        FILE="$YML_DIR"c2600.yml
        wget -O "$FILE" "$URL_C2600_YML" >/dev/null 2>&1
    fi

    SUBSTRING="c1760"
    if [[ "$NAME" == *"$SUBSTRING"* ]]; then
        FILE="$YML_DIR"c1760.yml
        wget -O "$FILE" "$URL_C1760_YML" >/dev/null 2>&1
    fi
}
```
