// JavaScript Document
var uploadPath='upload';//'/ws/upload';
	      //函数区
	    	var base={
	        	getEle:function (name,obj){  //以ID获取元素节点
	        		var obj=obj || document;
	        		return obj.getElementById(name);
	        	},
	        	addCls:function (obj,cn) {
	        		return obj.className += " " + cn;
	        	},
	        	delCls:function (obj,cn) {
	        		return obj.className = obj.className.replace(new RegExp("\\s*"+cn+"\\s*")," ");
	        	},
	        	hasCls:function (obj,cn) {
	        		return (new RegExp("\\b"+cn+"\\b")).test(obj.className);
	        	},
	        	getEleFromCls:function(obj,cn){
	        		var obj=obj || document;
	        		var allNode=obj.getElementsByTagName("*");
	        		var ret=[];
	        		for(var i in allNode){
	        			if(this.hasCls(allNode[i],cn)){
	        				ret.push(allNode[i]);
	        			}
	        		}
	        		return ret;
	        	},
	        	sToHex:function(str){
        	　　　　var val="";
        	　　　　for(var i = 0; i < str.length; i++){

        	　　　　　　if(val == "")
        	　　　　　　　　val = str.charCodeAt(i).toString(16);
        	　　　　　　else
        	　　　　　　　　val += "," + str.charCodeAt(i).toString(16);
        	　　　　}
        	　　　　return val;
        	　　},
	      		fixevt:function (evt){
					if(!evt.target){
						evt.target=evt.srcElement;//引起事件的对象
						if(evt.type=="mouseover")//引起事件相关的对象
							evt.relatedTarget=evt.fromElement;
						else if(evt.type=="mouseout")
							evt.relatedTarget=evt.toElement;
						evt.stopPropagation=function(){//阻止冒泡
							evt.cancelBubble=true;
						};
						evt.preventDefault=function(){//阻止默认行为
							evt.returnValue=false;
						};
						evt.charCode=(evt.type=="keypress")?evt.keyCode:0;
						evt.eventPhase=2;
						evt.timeStamp=(new Date()).getTime();
						
						evt.layerX=evt.offsetX;
						evt.layerY=evt.offsetY;
						
					}
					return evt;
				}
	    	}
	      
			var file={
	    		hasSend:[],
	    		fileInfo:function (obj) {
					var file = obj.files[0]||null;
					if (file) {
						var fileSize = 0;
			    		if (file.size > 1024 * 1024)
			    			fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
			    		else
			    			fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';
			     		return {
			    			name:file.name,
			    			size:fileSize,
			    			type:file.type,
			    			ksize:(Math.round(file.size * 100 / 1024) / 100)
			     		}
		    		}else{
		    			return false;
		    		}
				},
				uploadFile:function (obj) {
					var _this=this;
				    var fd = new FormData();
				    //关联表单数据,可以是自定义参数
				   	var fi=this.fileInfo(obj);
				    var name,ksize;
				    if(!fi){
				    	fd=null;
				    	alert('上传失败,请重试');
				    	return;
				    }
				    for(i in this.hasSend){
				    	if(this.hasSend[i]==name){
				    		fd=null;
					    	alert('此文件已上传');
					    	return;
				    	}
				    }
				    name=base.sToHex(fi.name);
				    ksize=fi.ksize;
				    this.addItems(fi.name,fi.size,obj.files[0],fi.type);
				    fd.append("fileToUpload", obj.files[0]);
				    
				    //监听事件
				   	var xhr = new XMLHttpRequest();
				    this[name+'i']=0;
				    this[name+'t']=new Date().getTime();
				    this[name+'per']=0;
				    xhr.upload.addEventListener("progress", function(e){_this.uploadProgress(e,name,ksize)}, false);
				    xhr.addEventListener("load", function(e){_this.uploadComplete(e,name)}, false);
				    xhr.addEventListener("error", function(e){_this.uploadFailed(e,name)}, false);
				    //发送文件和表单自定义参数
				    xhr.open("POST", uploadPath);
				    xhr.send(fd);
				},
				uploadProgress:function (evt,name,ksize) {
					if(this[name+'i']==0)base.getEleFromCls(base.getEle(name),'state')[0].innerHTML='发送中';
					this[name+'i']++;
				    if (evt.lengthComputable) {
				    	var t=new Date().getTime();
						var percentComplete = Math.round(evt.loaded * 100 / evt.total);
						var speed=(percentComplete===this[name+'per']?Math.random()*1000:ksize/(percentComplete-this[name+'per'])/100/((t-this[name+'t'])/1000)).toFixed(2);
						
						this[name+'t']=t;
						this[name+'per']=percentComplete;
						
						base.getEleFromCls(base.getEle(name),'prop')[0].innerHTML=percentComplete.toString() + '%';
						//base.getEleFromCls(base.getEle(name),'speed')[0].innerHTML=speed + 'KB/s';
						base.getEleFromCls(base.getEle(name),'top')[0].style.width=percentComplete.toString() + '%';
						
				    }else {
				    	this.uploadFailed(evt,name);
				    }
				},
				uploadComplete:function (evt,name) {
					base.getEleFromCls(base.getEle(name),'state')[0].innerHTML='已发送';
					this.hasSend.push(name);
					document.getElementById('top').style.background="#01cc99";
					
				},
				uploadFailed:function (evt,name) {
					base.getEleFromCls(base.getEle(name),'state')[0].innerHTML="已失败";
				},
				addItems:function(name,size,file,type){
					var str='<div id="'+base.sToHex(name)+'"><dl>'+
								'<dd style="overflow:hidden ;margin-left:0;"class="img_border"><img class="show" src="images/question.png"/></dd>'+
								'<dd class="middle">'+
									'<span class="sname">'+name+'</span>'+
									'<span class="ssize">'+size+'</span>'+
									'<span class="prop">0%</span>'+
									'<span class="back" id="mycolor"><span class="top"></span></span>'+
									
									//'<span class="speed">0%</span>'+
									
								'</dd>'+
								'<dd class="state_text">'+
									
									'<span class="state">等待</span>'+
								'</dd>'+
								'<p style="clear:both;"></p>'+
							'</dl></div>'+
						'</div>';
					base.getEle('sendCan').innerHTML=str+base.getEle('sendCan').innerHTML;
					this.preview(name,file,type);
				},
				preview:function(name,file,type){
					var img=base.getEleFromCls(base.getEle(base.sToHex(name)),'show')[0];
				
					var str = name;
					var kk = str.split(".");//以逗号作为分隔字符串
					var number=kk.length-1;
					if(/image/i.test(type)){
						var img;
						var url=URL.createObjectURL(file)
						img.src=url;					
					}else if(/video/i.test(type)){
						img.src='images/ic_select_video.png';
					}else if(/audio/i.test(type)){
						img.src='images/ic_music_purple_40dp.png';
					}else if(/zip/i.test(type)){
						img.src='images/ic_ysb_red40dp.png';
					}else if(/text/i.test(type)){
						img.src='images/ic_select_txt.png';
					}else{
						if(kk[number] == "api" || kk[number]== "mp4"|| kk[number]== "wmv"|| kk[number]== "rm"|| kk[number]== "rmvb"|| kk[number]== "mpg"|| kk[number]== "mpeg"){
							img.src='images/ic_select_video.png';}
							else if(kk[number] == "wma" || kk[number]== "mp3"|| kk[number]== "wav"|| kk[number]== "amr"){
							img.src='images/ic_music_purple_40dp.png';}
							else if(kk[number] == "apk"){img.src='images/ic_sdk_blue_40dp.png';}
						else{
						img.src='images/question.png';}
					}
				}
				
			}
					
		