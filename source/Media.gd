extends Node

enum Type {
	LOGO = 1 << 0,
	SCREENSHOT = 1 << 1,
	TITLE_SCREEN = 1 << 2,
	VIDEO = 1 << 3,
	BOX_RENDER = 1 << 4,
	BOX_TEXTURE = 1 << 5,
	SUPPORT_RENDER = 1 << 6,
	SUPPORT_TEXTURE = 1 << 7,
	MANUAL = 1 << 8,
	ALL = (1 << 9) - 1
}

var _media_cache := {}

func _clear_media_cache():
	_media_cache.clear()

func convert_type_bitmask_to_list(bitmask: int) -> Array:
	var arr := []
	if bitmask & Type.LOGO:
		arr.push_back(Type.LOGO)
	if bitmask & Type.SCREENSHOT:
		arr.push_back(Type.SCREENSHOT)
	if bitmask & Type.TITLE_SCREEN:
		arr.push_back(Type.TITLE_SCREEN)
	if bitmask & Type.VIDEO:
		arr.push_back(Type.VIDEO)
	if bitmask & Type.BOX_RENDER:
		arr.push_back(Type.BOX_RENDER)
	if bitmask & Type.BOX_TEXTURE:
		arr.push_back(Type.BOX_TEXTURE)
	if bitmask & Type.SUPPORT_RENDER:
		arr.push_back(Type.SUPPORT_RENDER)
	if bitmask & Type.SUPPORT_TEXTURE:
		arr.push_back(Type.SUPPORT_TEXTURE)
	if bitmask & Type.MANUAL:
		arr.push_back(Type.MANUAL)
	return arr

func convert_type_to_media_path(type: int) -> String:
	match type:
		Type.LOGO:
			return "logo"
		Type.SCREENSHOT:
			return "screenshot"
		Type.TITLE_SCREEN:
			return "title-screen"
		Type.VIDEO:
			return "video"
		Type.BOX_RENDER:
			return "box-render"
		Type.BOX_TEXTURE:
			return "box-texture"
		Type.SUPPORT_RENDER:
			return "support-render"
		Type.SUPPORT_TEXTURE:
			return "support-texture"
		Type.MANUAL:
			return "manual"
		_:
			return "unknown"


func retrieve_media_data(game_data: RetroHubGameData, types: int = Type.ALL) -> RetroHubGameMediaData:
	if not game_data.has_media:
		print("Error: game %s has no media" % game_data.name)
		return null

	if not _media_cache.has(game_data):
		_media_cache[game_data] = RetroHubGameMediaData.new()
	var game_media_data : RetroHubGameMediaData = _media_cache[game_data]

	var media_path = RetroHubConfig.get_gamemedia_dir() + "/" + game_data.system.name
	var game_path = game_data.path.get_file().get_basename()

	var image := Image.new()
	var file := File.new()
	var path : String

	# Logo
	path = media_path + "/logo/" + game_path + ".png"
	if types & Type.LOGO and file.file_exists(path):
		if image.load(path):
			print("Error when loading logo image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.logo = image_texture

	# Screenshot
	path = media_path + "/screenshot/" + game_path + ".png"
	if types & Type.SCREENSHOT and file.file_exists(path):
		if image.load(path):
			print("Error when loading screenshot image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.screenshot = image_texture

	# Title screen
	path = media_path + "/title-screen/" + game_path + ".png"
	if types & Type.TITLE_SCREEN and file.file_exists(path):
		if image.load(path):
			print("Error when loading title screen image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.title_screen = image_texture

	# Box render
	path = media_path + "/box-render/" + game_path + ".png"
	if types & Type.BOX_RENDER and file.file_exists(path):
		if image.load(path):
			print("Error when loading box render image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.box_render = image_texture

	# Box texture
	path = media_path + "/box-texture/" + game_path + ".png"
	if types & Type.BOX_TEXTURE and file.file_exists(path):
		if image.load(path):
			print("Error when loading box texture image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.box_texture = image_texture

	# Support render
	path = media_path + "/support-render/" + game_path + ".png"
	if types & Type.SUPPORT_RENDER and file.file_exists(path):
		if image.load(path):
			print("Error when loading support render image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.support_render = image_texture

	# Support texture
	path = media_path + "/support-texture/" + game_path + ".png"
	if types & Type.SUPPORT_TEXTURE and file.file_exists(path):
		if image.load(path):
			print("Error when loading support texture image for game %s!" % game_data.name)
		else:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image, 6)
			game_media_data.support_texture = image_texture

	# Video
	path = media_path + "/video/" + game_path + ".mp4"
	if types & Type.VIDEO and file.file_exists(path):
		var video_stream := VideoStreamGDNative.new()
		video_stream.set_file(path)
		game_media_data.video = video_stream

	# Manual
	## FIXME: Very likely we won't be able to support PDF reading.

	return game_media_data
