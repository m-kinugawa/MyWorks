{"filter":false,"title":"likes_controller.rb","tooltip":"/RailsTutorialSampleApp-master/app/controllers/likes_controller.rb","undoManager":{"mark":0,"position":0,"stack":[[{"start":{"row":0,"column":0},"end":{"row":11,"column":3},"action":"insert","lines":["class LikesController < ApplicationController","  def create","    @like = Like.create(user_id: current_user.id, micropost_id: params[:micropost_id])","    @likes = Like.where(micropost_id: params[:micropost_id])","  end","","  def destroy","    like = Like.find_by(user_id: current_user.id, micropost_id: params[:micropost_id])","    like.destroy","    @likes = Like.where(micropost_id: params[:micropost_id])","  end","end"],"id":1}]]},"ace":{"folds":[],"scrolltop":0,"scrollleft":0,"selection":{"start":{"row":11,"column":3},"end":{"row":11,"column":3},"isBackwards":false},"options":{"guessTabSize":true,"useWrapMode":false,"wrapToView":true},"firstLineState":{"row":5,"state":"start","mode":"ace/mode/ruby"}},"timestamp":1522769025981,"hash":"6457e7116c9fb97cf77c75c7aa681154c8a9d75a"}