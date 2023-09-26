
1. In your qb-core/server/player.lua please add the following:

PlayerData.metadata['storesrobbed'] = PlayerData.metadata['storesrobbed'] or 0
PlayerData.metadata['vangelicosrobbed'] = PlayerData.metadata['vangelicosrobbed'] or 0
PlayerData.metadata['fleecasrobbed'] = PlayerData.metadata['fleecasrobbed'] or 0
PlayerData.metadata['paletosrobbed'] = PlayerData.metadata['paletosrobbed'] or 0
PlayerData.metadata['pacificsrobbed'] = PlayerData.metadata['pacificsrobbed'] or 0
PlayerData.metadata['vaultsrobbed'] = PlayerData.metadata['vaultsrobbed'] or 0

2. In your qb-core/shared/items.lua please add the following:
Make sure to move the files in /images/ to your qb-inventory images.


['laptop_green'] = {['name'] = 'laptop_green', ['label'] = 'Green Laptop', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'laptop_green.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cracking the codes...'},
['laptop_blue'] = {['name'] = 'laptop_blue', ['label'] = 'Blue Laptop', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'laptop_blue.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cracking the codes...'},
['laptop_red'] = {['name'] = 'laptop_red', ['label'] = 'Red Laptop', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'laptop_red.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cracking the codes...'},
['laptop_gold'] = {['name'] = 'laptop_gold', ['label'] = 'Gold Laptop', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'laptop_gold.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cracking the codes...'},
['fleeca_keycard'] = {['name'] = 'fleeca_keycard', ['label'] = 'Fleeca Keycard', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'fleeca_keycard.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'I wonder what this unlocks.'},
['paleto_keycard'] = {['name'] = 'paleto_keycard', ['label'] = 'Paleto Keycard', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'paleto_keycard.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'I wonder what this unlocks.'},
['pacific_keycard'] = {['name'] = 'pacific_keycard', ['label'] = 'Pacific Keycard', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'pacific_keycard.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'I wonder what this unlocks.'},
['vault_keycard'] = {['name'] = 'vault_keycard', ['label'] = 'Vault Keycard', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'vault_keycard.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'I wonder what this unlocks.'},
['pacific_keys'] = {['name'] = 'pacific_keys', ['label'] = 'Pacific Keys', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'pacific_keys.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Who did you steal this from?!'},
['flashdrive'] = {['name'] = 'flashdrive', ['label'] = 'Flashdrive', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'flashdrive.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Is this the right way?'},
['vault_flashdrive'] = {['name'] = 'vault_flashdrive', ['label'] = 'Vault USB', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'vault_flashdrive.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Is this the right way?'},

3. Add the doorlocks from the /doorlocks/ folder to your qb-doorlocks/configs directory