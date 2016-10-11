# Description:
#   tamadora - Puzzle & Dragons assistant hubot
#
# Dependencies:
#   hubot
#
# Configuration:
#   set environment variable 'PAD_API_URL' to root url of pad monster api
#
# Commands:
#   pad <number>: get monster data of specific monster id
#   pad keyword: search for monsters by given keyword
#   TAMADORA TEST: test command
#
# Author:
#
#   hrs (hrs113355@gmail.com)

module.exports = (robot) ->
  show_monster = (monster, res) ->
    str = "No.#{monster.pad_id} #{monster.name} (#{monster.c_name})\n"
    if monster.rare >= 7
      str += ":star2: " for i in [1..monster.rare]
    else
      str += ":star: " for i in [1..monster.rare]
    str += "\n"

    str += "屬性: #{monster.element}"
    if monster.sub_element
      str += "/#{monster.sub_element}"
    str += "\nType: #{monster.type}"
    if monster.sub_type
      str += "/#{monster.sub_type}"

    
    str += "\n滿等需要經驗值: #{monster.need_exp}\n"

    if monster.mp?
      str += "販賣後可獲得 MP: #{monster.mp}\n"

    str += "滿等時HP: #{monster.hp} 攻擊: #{monster.atk} 回復: #{monster.rcv}\n"
    str += "主動技: #{monster.skill_name} (#{monster.skill_cd} -> #{monster.skill_min_cd})\n"
  
    if monster.skill_desc?
      skills = monster.skill_desc.split("\n")
      for skill in skills
        str += "> #{skill}\n"
  
    str += "隊長技: #{monster.lskill_name}\n"
  
    if monster.lskill_desc?
      lskills = monster.lskill_desc.split("\n")
      for lskill in lskills
        str += "> #{lskill}\n"
  
    str += "zh.pad.wikia.com/wiki/#{monster.pad_id}"
  
    res.send monster.icon.url
    res.send str

  robot.hear /pad (\d+)/i, (res) ->
    request = require('request')
    url = "#{process.env.PAD_API_URL}/#{res.match[1]}"

    request {
      url: url
      json: true
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        show_monster(body, res)
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
            show_monster(data, res)
      else
        res.send "塔麻找不到 :wave-bye: :lmao:"

  robot.hear /幹你山本/, (res) ->
    res.send "幹你山本 :kp:"

  robot.hear /幹你7x4/, (res) ->
    res.send "幹你7x4 :kp:"

  robot.hear /\.\.\./, (res) ->
    res.send "......"

  robot.hear /worship/i, (res) ->
    if Math.random() < 0.3
      res.send "強欸 m(_ _)m"

  robot.hear /TAMADORA TEST/, (res) ->
    res.send "receive test."

  robot.router.post '/hubot/notify/:room', (req, res) ->
    room = req.params.room
    message = req.body.message
    robot.messageRoom room, message
