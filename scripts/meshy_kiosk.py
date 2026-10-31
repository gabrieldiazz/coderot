"""Generate one documented lobby prop; never print or persist authentication."""
import json
from pathlib import Path
import sys
import tomllib
import urllib.request
import urllib.error

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'assets/meshy/kiosk'
MANIFEST = DEST / 'manifest.json'
PROMPT = ('One freestanding abandoned park information kiosk with a chunky CRT computer, '
          'slanted keyboard shelf, sturdy rectangular pedestal and small overhead canopy. '
          'Original early 2000s low polygon game prop. Strong simple silhouette, bevelled edges, '
          'large readable forms, muted teal painted metal and warm cream plastic, lightly worn. '
          'Screen is dark. No words, no logos, no people, no floor, no surrounding scene. '
          'Front faces forward, all pieces connected. Suitable as a small Roblox plaza prop.')

def main():
    with (ROOT / '.codex/config.toml').open('rb') as stream:
        key = tomllib.load(stream)['mcp_servers']['meshy-mcp-server']['env']['MESHY_API_KEY']
    def api(path, payload=None):
        request = urllib.request.Request('https://api.meshy.ai/openapi/' + path,
            data=json.dumps(payload).encode() if payload is not None else None,
            headers={'Authorization': 'Bearer ' + key, 'Content-Type': 'application/json'})
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)
    DEST.mkdir(parents=True, exist_ok=True)
    data = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {'prompt': PROMPT, 'tasks': {}}
    action = sys.argv[1]
    if action in ('preview', 'refine'):
        if action in data['tasks']:
            print('Task already recorded; refusing duplicate generation.')
            return
        if action == 'preview':
            data['balance_before'] = api('v1/balance')
            payload = {'mode': 'preview', 'prompt': PROMPT, 'ai_model': 'meshy-6',
                       'should_remesh': True, 'topology': 'triangle', 'target_polycount': 4000,
                       'target_formats': ['glb', 'fbx']}
        else:
            preview = api('v2/text-to-3d/' + data['tasks']['preview']['id'])
            if preview['status'] != 'SUCCEEDED':
                print('Preview is not ready.'); return
            payload = {'mode': 'refine', 'preview_task_id': preview['id'], 'enable_pbr': False,
                       'texture_prompt': 'Muted teal painted metal, cream CRT bezel, dark glass screen, subtle dirt and chipped edges. No text, no logos. Stylized low-poly retro game prop.',
                       'target_formats': ['glb', 'fbx']}
        data['tasks'][action] = {'id': api('v2/text-to-3d', payload)['result'], 'request': payload}
    elif action in ('status', 'download'):
        for stage, record in data['tasks'].items():
            result = api('v2/text-to-3d/' + record['id'])
            record.update({k: result[k] for k in ('status', 'progress', 'consumed_credits') if k in result})
            if action == 'download' and result['status'] == 'SUCCEEDED':
                urls = dict(result.get('model_urls', {}))
                if result.get('thumbnail_url'): urls['png'] = result['thumbnail_url']
                for extension, url in urls.items():
                    if extension not in ('glb', 'fbx', 'png') or not url: continue
                    # Signed asset URLs stay in memory, not in committed metadata.
                    with urllib.request.urlopen(url, timeout=60) as response:
                        (DEST / (stage + '.' + extension)).write_bytes(response.read())
                for index, textures in enumerate(result.get('texture_urls', [])):
                    url = textures.get('base_color')
                    if url:
                        with urllib.request.urlopen(url, timeout=60) as response:
                            (DEST / (stage + '-base-color-' + str(index) + '.png')).write_bytes(response.read())
                record['files'] = sorted(p.name for p in DEST.glob(stage + '*') if p.is_file())
        data['balance_after'] = api('v1/balance')
    MANIFEST.write_text(json.dumps(data, indent=2) + '\n')
    print(json.dumps(data, indent=2))

if __name__ == '__main__':
    try:
        main()
    except urllib.error.HTTPError as error:
        print('Meshy HTTP status:', error.code); sys.exit(1)
    except urllib.error.URLError:
        print('Network unavailable; retry with network permission.'); sys.exit(2)
