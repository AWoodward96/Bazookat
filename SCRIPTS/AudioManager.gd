extends Node2D
# Will probably find a use for this later

# I'm comfortable with hard coding these because
# These should literally never change
const MUSIC_BUS_GUID = "{d8bbe9b1-d635-4783-9b8f-b9185727b3b1}"
const SFX_BUS_GUID =  "{1d1d4f99-55b6-44a9-bedb-58025f35747a}"
const UI_BUS_GUID = "{cca63318-3343-47f1-9525-2ec1f3ef1ce6}"
const MASTER_BUS_GUID = "{294db87e-5254-4e62-96fa-0ec36e195bdd}"

@export var e_fModBanks : FmodBankLoader

var m_musicBus : FmodBus
var m_sfxBus : FmodBus
var m_uiBus : FmodBus
var m_masterBus : FmodBus

func _ready():
	m_musicBus = FmodServer.get_bus_from_guid(MUSIC_BUS_GUID)
	m_sfxBus = FmodServer.get_bus_from_guid(SFX_BUS_GUID)
	m_uiBus = FmodServer.get_bus_from_guid(UI_BUS_GUID)
	m_masterBus = FmodServer.get_bus_from_guid(MASTER_BUS_GUID)
	pass

func SetMusicVolume(_volume : float):
	m_musicBus.volume = _volume

func SetSFXVolume(_volume : float):
	m_sfxBus.volume = _volume

func SetMasterVolume(_volume : float):
	m_masterBus.volume = _volume

func SetUIVolume(_volume : float):
	m_uiBus.volume = _volume
