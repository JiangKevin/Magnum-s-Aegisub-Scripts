	script_name        = "Break Line"
	script_description = "Satırlara bölme karakteri ekler."
	script_author      = "Magnum357"
	script_version     = "1"

	mag_import, mag = pcall(require,"mag")

	function line_breaker(subs,sel,config)
	local pcs          = false
	local style_name   = mag.unstyles(config["u_style_name"])
	local comment_line = config["u_comment_line"]
	local max_char     = config["u_max_char"]
	local talking      = config["u_talking"]
	local balance      = config["u_balance"]
	for i = 1, #subs do
	local line = subs[i]
		if line.class == "dialogue" then
		local style1, style2 = line.style, style_name
		if style_name == "Tüm stiller" then style1, style2 = 1, 1 end
		local comment1, comment2 = line.comment, false
		if not comment_line then comment1, comment2 = 1, 1 end
			local text_len = len(line.text)
			local _, talk = mag.gsub(mag.full_strip(line.text),"%-%s[A-Za-zöÖüÜçÇıİ]","")
			if style1 == style2 and comment1 == comment2 then
				if not mag.match(line.text,"\\N") and talking and talk == 2 then
				pcs = true
				local w, word = mag.words(line.text)
				local talk_counter = 0
				local tt = ""
					for k = 1, w do
					if mag.match(mag.full_strip(word[k]),"%-%s") then talk_counter = talk_counter + 1 end
					if talk_counter == 2 then tt = tt.."\\N" talk_counter = 0 end
					tt = tt..word[k]
					end
				line.text = tt
				end
				if not mag.match(line.text,"\\N") and mag.match(line.text," ") and max_char <= text_len then
				pcs = true
				local text_half_len = mag.floor(len(line.text) / 2)
				local w, word = mag.words(line.text)
				local cc      = 0
				local ptext   = ""
				local ntext   = ""
				local kp      = 0
					if not balance then
						for k = 1, w do
						cc = cc + len(word[k])
							if cc <= text_half_len then
							ptext = ptext..word[k]
							kp    = k
							else
							ntext = ntext..word[k]
							end
						end
						if len(ntext) - len(ptext) >= 10 then
						ptext = ""
						ntext = ""
							for t = 1, w do
								if t <= kp + 1 then
								ptext = ptext..word[t]
								else
								ntext = ntext..word[t]
								end
							end
						end
					else
					local last_diff = {}
						repeat
						ptext = ""
						ntext = ""
						kp = kp + 1
							for k = 1, w do
								if k <= kp then
								ptext = ptext..word[k]
								else
								ntext = ntext..word[k]
								end
							end
						table.insert(last_diff,mag.positive(len(ntext) - len(ptext)))
						if w == kp then break end
						until false
					local ldiff
						for j = 1, table.getn(last_diff) - 1 do
						if last_diff[j] < last_diff[j + 1] then ldiff = j break end
						end
					ptext = ""
					ntext = ""
						for g = 1, w do
							if g <= ldiff then
							ptext = ptext..word[g]
							else
							ntext = ntext..word[g]
							end
						end
					end
				line.text = ptext.."\\N"..ntext
				end
				if pcs then subs[i] = line end
			end
		end
	end
	if not pcs then mag.log(2,"Hiçbir işlem yapılmadı.") end
	end

	function len(str) return mag.len(mag.removedot(mag.full_strip(str))) end

	function gui(subs)
	local dialog_config =
	{{class = "label",                                                                        x = 0, y = 0, width = 1, height = 1, label = "Karakter sınırı:"}
	,{class = "intedit",  name = "u_max_char",     value = 44,            min = 35, max = 50, x = 1, y = 0, width = 1, height = 1}
	,{class = "label",                                                                        x = 0, y = 1, width = 1, height = 1, label = mag.wall(" ",18).."Stil:"}
	,{class = "dropdown", name = "u_style_name",   value = "Tüm stiller",                     x = 1, y = 1, width = 1, height = 1, items = {"Tüm stiller"}, hint = "Sadece kullanılan stiller listelenir. İlk sayı yorum satırı yapılmamış iken ikinci sayı yapılmış satırların sayısıdır."}
	,{class = "checkbox", name = "u_comment_line",                                            x = 1, y = 2, width = 1, height = 1, label = "Yorum satırlarını geç."}
	,{class = "checkbox", name = "u_talking",      value = true,                              x = 1, y = 3, width = 1, height = 1, label = "Konuşma çizgilerini çizgiden böl.", hint = "Karakter sınırının altında veya üstünde olan ikili konuşma satırlarını konuşma çizgisinden böler. "}
	,{class = "checkbox", name = "u_balance",                                                 x = 1, y = 4, width = 1, height = 1, label = "Dengeli böl."}
	}
	mag.styles_insert(subs,dialog_config,4,"comment","")
	return dialog_config
	end

	function add_macro(subs)
	local ok, config = mag.dlg(gui(subs),{"Böl","Kapat"})
	if ok == mag.ascii("Böl") then
	line_breaker(subs,sel,config)
    aegisub.set_undo_point(script_name)
	end
	end

	if mag_import then mag.register(false,add_macro) else function mag()
	local k = aegisub.dialog.display({{class = "label", label="Mag modülü bulunamadı. \nBu lua dosyasını kullanmak için Mag modülünü İndirmek ister misiniz?"}},{"Evet","Kapat"})
	if k == "Evet" then os.execute("start https://github.com/magnum357i/Magnum-s-Aegisub-Scripts") end end
	aegisub.register_macro(script_name,script_desription,mag) end