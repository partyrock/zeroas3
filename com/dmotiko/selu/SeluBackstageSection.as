﻿package com.dmotiko.selu {
	
	import fl.transitions.easing.*;
	import fl.transitions.*;
	import flash.display.*;
	import flash.events.*
	import com.general.*
	import fl.video.*;
		
	public class SeluBackstageSection
	extends BaseClip {
		
		private var videoPlayer:FLVPlayback;
		private var playButton:Sprite;
		private var pauseButton:Sprite;
		private var stopButton:Sprite;
		private var seekBar:Sprite;
		private var volumeController:Object;
		private var tVolume:Tween;
				
		override protected function initClip():void {
			super.initClip();
			//trace("SeluBackstageSection initClip "+this);
			
			SeluSite.getApp().addEventListener( WebSite.SECTION_CHANGED, section_changed);
			SeluSite.getApp().addEventListener( WebSite.SOUND_CHANGED, sound_changed);
			
			//recolecto los movieclips que están en el fla
			playButton = getChildByName("mcPlay") as Sprite;
			pauseButton = getChildByName("mcPause") as Sprite;
			stopButton = getChildByName("mcStop") as Sprite;
			seekBar = getChildByName("mcSeek") as Sprite;
			videoPlayer = getChildByName("flvPlayer") as FLVPlayback;
						
			//inicializo los clips
			playButton.buttonMode = pauseButton.buttonMode = stopButton.buttonMode = true;
			playButton.addEventListener( MouseEvent.ROLL_OVER, btn_over );
			playButton.addEventListener( MouseEvent.ROLL_OUT, btn_out);
			pauseButton.addEventListener( MouseEvent.ROLL_OVER, btn_over );
			pauseButton.addEventListener( MouseEvent.ROLL_OUT, btn_out);
			stopButton.addEventListener( MouseEvent.ROLL_OVER, btn_over );
			stopButton.addEventListener( MouseEvent.ROLL_OUT, btn_out);
			stopButton.addEventListener( MouseEvent.CLICK, reset_video);
			
			videoPlayer.playButton = playButton;
			videoPlayer.pauseButton = pauseButton;
			videoPlayer.stopButton = stopButton;
			videoPlayer.seekBar = seekBar;
			videoPlayer.autoPlay = false;
			videoPlayer.addEventListener(VideoEvent.STATE_CHANGE, video_change);
			videoPlayer.load("http://www.d-motiko.com.ar/clients/selu/production/backstage.flv");
			volumeController = new Object();
			if ( SeluSite.getApp().getSound() ) volumeController.volume = 1;
			else volumeController.volume = 0;
		}
		
		private function sound_changed(e:Event):void {
			if ( SeluSite.getApp().getSection() != SeluSite.BACKSTAGE) return;
			if ( SeluSite.getApp().getSound() ) {
				//volumeController.volume = 1;
				videoFadeIn();
			} else {
				videoFadeOut();
			}
			
		}
						
		private function video_change(e:VideoEvent):void {
			SeluSite.getApp().log("video_change= " + e.state);
		}
		
		private function section_changed(e:Event):void {
			if ( SeluSite.getApp().getSection() == SeluSite.BACKSTAGE ) {
				videoPlayer.playWhenEnoughDownloaded();
				if ( !SeluSite.getApp().getSound() ) return;
				videoFadeIn();
			} else {
				if( videoPlayer.state != "stopped"){
					if ( !SeluSite.getApp().getSound() ) {
						stop_flv(undefined);
						return;
					}
					videoFadeOut();
				}
				SeluSite.getApp().fadeInMusic();
			}
		}
		
		private function videoFadeOut():void {
			if ( tVolume ) tVolume.stop();
			tVolume = new Tween(volumeController, "volume", Regular.easeOut, volumeController.volume, 0, 2, true);
			tVolume.addEventListener( TweenEvent.MOTION_CHANGE, refresh_volume);
			tVolume.addEventListener( TweenEvent.MOTION_FINISH, stop_flv);
		}
		
		private function videoFadeIn():void	{
			if ( tVolume ) tVolume.stop();
			tVolume = new Tween(volumeController, "volume", Regular.easeOut, volumeController.volume, 1, 2, true);
			tVolume.addEventListener( TweenEvent.MOTION_CHANGE, refresh_volume);
			SeluSite.getApp().fadeOutMusic();
		}
		
		private function refresh_volume(e:TweenEvent):void {
			videoPlayer.volume = volumeController.volume;
		}
		
		private function stop_flv(e:TweenEvent):void {
			videoPlayer.seek(0);
			videoPlayer.stop();
		}
		
		private function reset_video(e:MouseEvent):void {
			videoPlayer.seekPercent(0);
		}
		
		private function btn_over( e:MouseEvent ):void {
			var btn:Sprite = e.currentTarget as Sprite;
			killTween( "btnOver" );
			registerTween("btnOver", new Tween( btn, "alpha", Regular.easeOut, btn.alpha, 0.7, 0.3, true) );
		}
		private function btn_out( e:MouseEvent ):void {
			var btn:Sprite = e.currentTarget as Sprite;
			killTween( "btnOut" );
			registerTween("btnOut", new Tween( btn, "alpha", Regular.easeOut, btn.alpha, 1, 0.3, true) );
		}
		
		
	}
	
}