const AVAILABLE_IMG_TYPES = [
  ['system', 'arm64', 'GAPPS'],
  ['system', 'x86_64', 'GAPPS'],

  ['system', 'arm64', 'VANILLA'],
  ['system', 'x86_64', 'VANILLA'],

  ['vendor', 'arm64', 'MAINLINE'],
  ['vendor', 'x86_64', 'MAINLINE']
];

const FRIENDLY_ARCH_NAME = { arm64: 'ARM64', x86_64: 'x86-64' },
      channelSelector    = document.querySelector('#channel-selector > select');

async function getLatestRelease(img, arch, type, variant) {
  const update_channel = await fetch(`${variant}/${img == 'system' ? 'system/lineage' : img}/waydroid_${arch}/${type}.json`).then(r => r.json());
  return update_channel.response[0];
}

async function updateTable(img, arch, type, variant) {
  const table          = document.getElementById(`${img}-images`),
        img_table_elem = document.createElement('tr');

  table.appendChild(img_table_elem);

  const img_info = await getLatestRelease(img, arch, type, variant);

  img_table_elem.innerHTML = `
    <td>${FRIENDLY_ARCH_NAME[arch]}</td>
    <td>LineageOS ${img_info.version}</td>
    <td>${type}</td>
    <td>${img_info.url.match(/lineage-[\d\.]+-(\d{4})(\d{2})(\d{2})/).slice(1).join('-')}</td>
    <td>${img_info.asb}</td>
    <td><a class="button" href="${img_info.url}">SourceForge</a></td>
  `;
}

function onChannelUpdate() {
  const tables = document.querySelectorAll(`.list > table`);

  tables[0].innerHTML = tables[0].innerHTML.replace(/(?<=\<\/tbody\>).*/s, '');
  tables[1].innerHTML = tables[1].innerHTML.replace(/(?<=\<\/tbody\>).*/s, '');

  for (type of AVAILABLE_IMG_TYPES) {
    updateTable(...type, channelSelector.value);
  }
}

channelSelector.onchange = window.onload = () => onChannelUpdate();
