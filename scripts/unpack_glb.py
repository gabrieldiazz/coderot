"""Losslessly unpack a GLB to a glTF JSON + local binary for Studio import."""
import json
from pathlib import Path
import struct
import sys

source = Path(sys.argv[1])
raw = source.read_bytes()
magic, version, total = struct.unpack_from('<III', raw)
if magic != 0x46546C67 or version != 2 or total != len(raw):
    raise ValueError('Expected a complete GLB 2 file')
chunks = {}
offset = 12
while offset < total:
    length, kind = struct.unpack_from('<II', raw, offset)
    offset += 8
    chunks[kind] = raw[offset:offset + length]
    offset += length
document = json.loads(chunks[0x4E4F534A])
if len(document.get('buffers', [])) != 1:
    raise ValueError('Expected one embedded buffer')
length = document['buffers'][0]['byteLength']
source.with_suffix('.bin').write_bytes(chunks[0x004E4942][:length])
document['buffers'][0]['uri'] = source.with_suffix('.bin').name
source.with_suffix('.gltf').write_text(json.dumps(document, indent=2) + '\n')
print('Unpacked', source.name, 'to glTF and BIN; embedded images remain in the buffer.')
