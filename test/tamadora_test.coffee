Helper = require('hubot-test-helper')
expect = require('chai').expect
Promise = require('bluebird')
co = require('co')

# helper loads a specific script if it's a file
helper = new Helper('./../scripts/pad.coffee')

describe 'tamadora test', ->
  this.timeout(8000)
  room = null

  beforeEach ->
    # Set up the room before running the test
    room = helper.createRoom()

  afterEach ->
    # Tear it down after the test to free up the listener.
    room.destroy()

  context 'tamadora reply hard strings', ->
    beforeEach ->
      co =>
        yield room.user.say 'alice', 'TAMADORA TEST'

    it 'replies "receive test." when user request TAMADORA TEST', ->
      expect(room.messages).to.eql [
        ['alice', 'TAMADORA TEST']
        ['hubot', 'receive test.']
      ]

  context 'tamadora reply monster data', ->
    beforeEach ->
      co =>
        yield room.user.say 'alice', 'pad 1'
        yield new Promise.delay(3500)

    it 'replies monster data query by pad id', ->
      expect(room.messages[1][1]).to.contain('amazonaws')
      expect(room.messages[2][1]).to.contain('提拉')

  context 'tamadora reply monster data', ->
    beforeEach ->
      co =>
        yield room.user.say 'alice', 'pad 5566'
        yield new Promise.delay(3500)

    it 'replies not found when specific id is not found', ->
      expect(room.messages[1][1]).to.contain('塔麻找不到')

  context 'tamadora display monster rarity with star', ->
    beforeEach ->
      co =>
        yield room.user.say 'alice', 'pad 689'
        yield new Promise.delay(3500)

    it 'displays monster rarity with star emoticon', ->
      expect(room.messages[2][1]).to.contain(':star:')

  context 'tamadora display monster rarity with star', ->
    beforeEach ->
      co =>
        yield room.user.say 'alice', 'pad 2292' # 水着パンドラ (rarity = 7)
        yield new Promise.delay(3500)

    it 'displays monster rarity with star2 emoticon when monster is very rare', ->
      expect(room.messages[2][1]).to.contain(':star2:')

