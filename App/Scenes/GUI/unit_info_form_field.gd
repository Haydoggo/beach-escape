extends HBoxContainer



func activate(title: String, value : String):
	$Title.text = title
	$Value.text = value
	if title == "name":
		$Title.hide()

