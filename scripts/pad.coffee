module.exports = (robot) ->
  robot.hear /pad (\d+)/i, (res) ->
    request = require('request')
    url = "#{process.env.PAD_API_URL}/#{res.match[1]}"

    request {
      url: url
      json: true
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        data = body
  
        str = "No.#{data.pad_id} #{data.name} (#{data.c_name})\n屬性: #{data.element}"
        if data.sub_element
          str += "/#{data.sub_element}"
        str += "\nType: #{data.type}"
        if data.sub_type
          str += "/#{data.sub_type}"
        str += "\n滿等需要經驗值: #{data.need_exp}\n"
        str += "滿等時HP: #{data.hp} 攻擊: #{data.atk} 回復: #{data.rcv}\n"
        str += "主動技: #{data.skill_name} (#{data.skill_cd} -> #{data.skill_min_cd})\n"
  
        if data.skill_desc?
          skills = data.skill_desc.split("\n")
          for skill in skills
            str += "> #{skill}\n"
  
        str += "隊長技: #{data.lskill_name}\n"
  
        if data.lskill_desc?
          lskills = data.lskill_desc.split("\n")
          for lskill in lskills
            str += "> #{lskill}\n"
  
        str += "zh.pad.wikia.com/wiki/#{data.pad_id}"
  
        res.send data.icon.url
        res.send str
      else
        res.send "塔麻找不到 :wave-bye: :lmao:"

  robot.hear /pad ([^0-9 ]+) ?(\d+)?/i, (res) ->
    keyword = res.match[1]
    page = parseInt(res.match[2])

    request = require('request')
    url = "#{process.env.PAD_API_URL}/search?keyword=#{encodeURIComponent(keyword)}"
    if !isNaN(page)
      url += "&page=#{page}"

    request {
      url: url
      json: true
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        data = body
        monsters = data.monsters

        str = "有關 #{keyword} 的搜尋總共有 #{data.total_count} 筆 (共 #{data.total_page} 頁)\n"
        if data.total_page > 1
          str += "一頁最多顯示 5 筆，可以使用 `pad #{keyword} N` 查詢第 N 頁的結果\n"
        if data.total_page != 0
          str += "以下顯示第 #{data.page} 頁的結果\n"
        res.send str

        if data.total_count == 0
          res.send "塔麻找不到 :wave-bye: :lmao:"
        else
          for data in monsters
            str = "No.#{data.pad_id} #{data.name} (#{data.c_name})\n屬性: #{data.element}"
            if data.sub_element
              str += "/#{data.sub_element}"
            str += "\nType: #{data.type}"
            if data.sub_type
              str += "/#{data.sub_type}"
            str += "\n滿等需要經驗值: #{data.need_exp}\n"
            str += "滿等時HP: #{data.hp} 攻擊: #{data.atk} 回復: #{data.rcv}\n"
            str += "主動技: #{data.skill_name} (#{data.skill_cd} -> #{data.skill_min_cd})\n"
      
            if data.skill_desc?
              skills = data.skill_desc.split("\n")
              for skill in skills
                str += "> #{skill}\n"
      
            str += "隊長技: #{data.lskill_name}\n"
      
            if data.lskill_desc?
              lskills = data.lskill_desc.split("\n")
              for lskill in lskills
                str += "> #{lskill}\n"
      
            str += "zh.pad.wikia.com/wiki/#{data.pad_id}"
      
            res.send data.icon.url
            res.send str
      else
        res.send "塔麻找不到 :wave-bye: :lmao:"

  robot.hear /(幹|山本)/, (res) ->
    res.send "幹你山本 :kp:"

  robot.hear /worship/i, (res) ->
    if Math.random() < 0.1
      res.send "強欸 :wave-bye:"

  robot.router.post '/hubot/notify/:room', (req, res) ->
    room = req.params.room
    message = req.body.message
    robot.messageRoom room, message
