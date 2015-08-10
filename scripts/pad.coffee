module.exports = (robot) ->
  robot.hear /pad (\d+)/i, (res) ->
    sqlite3 = require('sqlite3').verbose()

    db = new sqlite3.Database('./pad.sqlite')
    db.serialize () ->
      db.all "select * from monsters where pad_id=" + res.match[1], (err, rows) ->
        if (rows.length == 0)
          res.send "塔麻找不到 :wave-bye:"
        else
          row = rows[0]

          str = "No.#{row.pad_id} #{row.name} (#{row.c_name})\n屬性: #{row.element}"
          if row.sub_element
            str += "/#{row.sub_element}"
          str += "\nType: #{row.type}"
          if row.sub_type
            str += "/#{row.sub_type}"
          str += "\n滿等需要經驗值: #{row.need_exp}\n"
          str += "滿等時HP: #{row.hp} 攻擊: #{row.atk} 回復: #{row.rcv}\n"
          str += "主動技: #{row.skill_name} (#{row.skill_cd} -> #{row.skill_min_cd})\n"

          skills = row.skill.split("\n")
          for skill in skills
            str += "> #{skill}\n"

          str += "隊長技: #{row.lskill_name}\n"

          lskills = row.lskill.split("\n")
          for lskill in lskills
            str += "> #{lskill}\n"

          str += "http://zh.pad.wikia.com/wiki/#{row.pad_id}"

          res.send "https://dl.dropboxusercontent.com/u/78642/pad/pet_icons/#{res.match[1]}.png"
          res.send str
    db.close()

  robot.hear /pad ([^0-9 ]+) ?(\d+)?/i, (res) ->
    sqlite3 = require('sqlite3').verbose()
    db = new sqlite3.Database('./pad.sqlite')
    keyword = res.match[1]
    page = parseInt(res.match[2])

    if isNaN(page) || page <= 1
      offset = 0
    else
      offset = (page - 1) * 5

    db.serialize () ->
      db.all "select count(id) as idcount from monsters where name like $keyword or c_name like $keyword", {$keyword: "%#{keyword}%"}, (err, rows) ->
        str = "有關 #{keyword} 的搜尋總共有 #{rows[0].idcount} 筆 (共 #{Math.ceil(rows[0].idcount / 5)} 頁)\n"
        if rows[0].idcount > 5
          str += "一頁最多顯示 5 筆，可以使用 `pad #{keyword} N` 查詢第 N 頁的結果\n"
        if ! isNaN(page)
          str += "以下顯示第 #{page} 頁的結果\n"

        res.send str

      db.all 'select * from monsters where name like $keyword or c_name like $keyword order by id asc limit 5 offset $offset', {$keyword: "%#{keyword}%", $offset: offset}, (err, rows) ->
        if rows.length == 0
          res.send "塔麻找不到 :wave-bye:"
        else
          for row in rows
            str = "No.#{row.pad_id} #{row.name} (#{row.c_name})\n屬性: #{row.element}"
            if row.sub_element
              str += "/#{row.sub_element}"
            str += "\nType: #{row.type}"
            if row.sub_type
              str += "/#{row.sub_type}"
            str += "\n滿等需要經驗值: #{row.need_exp}\n"
            str += "滿等時HP: #{row.hp} 攻擊: #{row.atk} 回復: #{row.rcv}\n"
            str += "主動技: #{row.skill_name} (#{row.skill_cd} -> #{row.skill_min_cd})\n"
  
            skills = row.skill.split("\n")
            for skill in skills
              str += "> #{skill}\n"
  
            str += "隊長技: #{row.lskill_name}\n"
  
            lskills = row.lskill.split("\n")
            for lskill in lskills
              str += "> #{lskill}\n"
  
            str += "http://zh.pad.wikia.com/wiki/#{row.pad_id}"
  
            res.send "https://dl.dropboxusercontent.com/u/78642/pad/pet_icons/#{row.pad_id}.png"
            res.send str
    db.close()
