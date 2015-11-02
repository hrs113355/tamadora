expect = require('chai').expect
helper = require 'hubot-mock-adapter-helper'
 
TextMessage = require('hubot/src/message').TextMessage
 
describe 'tamadora test', ->
  {robot, user, adapter} = {}
 
  beforeEach (done) ->
    helper.setupRobot (ret) ->
      {robot, user, adapter} = ret
      done()
 
  afterEach ->
    robot.shutdown()
 
  it 'responds test', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      expect(envelope.user.name).to.equal('mocha')
      expect(strings[0]).to.not.equal("receive test.")
    , done()
 
    adapter.receive(new TextMessage(user, 'TAMADORA TEST'))
