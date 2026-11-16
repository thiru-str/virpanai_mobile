"""Inspect the ELF headers of every native library shipped in an AAB."""

import argparse
import json
import struct
import zipfile


def inspect_elf(name, data):
    if data[:4] != b"\x7fELF":
        raise ValueError(f"Not an ELF library: {name}")
    is_64 = data[4] == 2
    endian = "<" if data[5] == 1 else ">"
    if is_64:
        offset = struct.unpack_from(endian + "Q", data, 32)[0]
        entry_size, count = struct.unpack_from(endian + "HH", data, 54)
        format_string = endian + "IIQQQQQQ"
    else:
        offset = struct.unpack_from(endian + "I", data, 28)[0]
        entry_size, count = struct.unpack_from(endian + "HH", data, 42)
        format_string = endian + "IIIIIIII"
    loads = []
    relro = []
    writable_ranges = []
    relro_ranges = []
    for index in range(count):
        header = struct.unpack_from(format_string, data, offset + index * entry_size)
        if is_64:
            kind, flags, file_offset, virtual_address, _, _, memory_size, alignment = header
        else:
            kind, file_offset, virtual_address, _, _, memory_size, flags, alignment = header
        if kind == 1:
            loads.append({
                "alignment": alignment,
                "offset_congruent_16kb": file_offset % 16384 == virtual_address % 16384,
            })
            if flags & 2:
                writable_ranges.append((virtual_address, virtual_address + memory_size))
        elif kind == 0x6474E552:
            relro.append((virtual_address + memory_size) % 16384 == 0)
            relro_ranges.append((virtual_address, virtual_address + memory_size))
    # Bionic rounds RELRO protection to whole pages. Check whether that range
    # would cover writable data outside RELRO, including other LOAD segments.
    unprotected_ranges = writable_ranges
    for start, end in relro_ranges:
        remaining = []
        for low, high in unprotected_ranges:
            if start >= high or end <= low:
                remaining.append((low, high))
            else:
                if low < start:
                    remaining.append((low, start))
                if end < high:
                    remaining.append((end, high))
        unprotected_ranges = remaining
    relro_safe = all(
        not any(low < ((end + 16383) // 16384) * 16384
                and high > (start // 16384) * 16384
                for low, high in unprotected_ranges)
        for start, end in relro_ranges
    )
    aligned = bool(loads) and all(
        item["alignment"] >= 16384 and item["offset_congruent_16kb"]
        for item in loads
    )
    return {
        "library": name,
        "is_64_bit": is_64,
        "load_segments": loads,
        "elf_16kb_aligned": aligned,
        "relro_end_16kb_aligned": all(relro),
        "relro_no_writable_overlap_16kb": relro_safe,
        "has_relro": bool(relro),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle")
    args = parser.parse_args()
    with zipfile.ZipFile(args.bundle) as archive:
        results = [
            inspect_elf(item.filename, archive.read(item))
            for item in archive.infolist()
            if item.filename.endswith(".so")
        ]
    failures = [
        item["library"] for item in results
        if item["is_64_bit"]
        and (not item["elf_16kb_aligned"] or not item["relro_no_writable_overlap_16kb"])
    ]
    print(json.dumps({"libraries": results, "failures_64_bit": failures}, indent=2))
    raise SystemExit(1 if failures or not results else 0)


if __name__ == "__main__":
    main()
