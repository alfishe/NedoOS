var curDir='';
var s;
var xhr;
var fileToUp;
var fCnt;
var r;
var cyr866="АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмноп░▒▓│┤╡╢╖╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀рстуфхцчшщъыьэюяЁёЄєЇїЎў°∙·√№¤■ ";
function to866(str){
	var s866="";
	for(var i=0;i<str.length;i++){
		var ch=str.charCodeAt(i);
		if(ch>127){
			ch=cyr866.indexOf(str[i])+128;
			if(ch>=0){s866+="%"+ch.toString(16).toUpperCase();}
			else{s866+="x";}
		}else{
			s866+=str[i];
		}
	}
	return s866;
}
function myGet(u) {
	var r = new XMLHttpRequest();
	r.open("GET", to866(u)+"&r="+Math.random(), false);
	r.send(null);	
	return r.responseText;
}

function mkdir(){
	var ss = '?m='+window.curDir+'/'+document.getElementById('dirName').value;
	document.getElementById('log').innerHTML=myGet(ss);
	rddir(window.curDir);
}

function unlink(dirPath){ 
	var ss = '?u='+window.curDir+'/'+dirPath;
	document.getElementById('log').innerHTML=myGet(ss);
	rddir(window.curDir);
}
function compareFileInfo(finfoA, finfoB) {
	if(finfoA.isdir==3 || finfoB.isdir==3) return 0;
	return finfoA.fn.localeCompare(finfoB.fn);
}
function rddir(dirPath){
	var i=0;
	var k=0;
	window.s='';
	window.curDir=dirPath;
	window.s+='Current dir: <a href="javascript:rddir(\'\')">0:</a>';
	if(dirPath!=''){
		while((k=dirPath.indexOf('/',i))!=-1){
			window.s+='<a href="javascript:rddir(\''+dirPath.substring(0,k)+'\')">'+
				dirPath.substring(i,k-i)+'</a>/';
			i=k+1;
		}
		window.s+=dirPath.substring(i);
	}
	window.s+='<br><table>';
	j=JSON.parse(myGet('?d='+dirPath));
	j.fno.sort(compareFileInfo);
	j.fno.forEach(function(item, i, arr) {
		var n,pn;
		if(item.isdir==1){
			if(item.ln!='')n=item.ln;
			else {
				n=item.fn.replace(/([^ ]{0,8}) */,'$1');
			}
			if(n=='..')pn=dirPath.substr(0,dirPath.lastIndexOf('/'));
			else pn=((dirPath=='')?(''):(dirPath+'/'))+n;
			if(n!="."){
				window.s+='<tr>';
				
					window.s+='<td><a href="javascript:rddir(\''+pn+'\')">'+n+'</a></td><td></td><td>';
				
				window.s+='</td><td><a href="javascript:unlink(\''+n+'\')"><img src="fdel.png" alt="del"></a><td>';
				window.s+='</tr>';
			}
		}
	});	
	j.fno.forEach(function(item, i, arr) {
		var n,pn;
		if(item.isdir==0){
			if(item.ln!='')n=item.ln;
			else {
				n=item.fn.replace(/([^ ]{0,8}) *()/,'$1.$2');
			}
			pn=((dirPath=='')?(''):(dirPath+'/'))+n;
			window.s+='<tr>';
			
				window.s+='<td>'+n+'</td><td>'+item.sz+'B </td><td>'+'<a href="?g='+pn+'"><img src="dload.png" alt="download"></a>';
				//if(n.toLowerCase().substring(n.length-4)=='.pt3')s+='<a href="?p='+pn+'">Play</a>';
			
			window.s+='</td><td><a href="javascript:unlink(\''+n+'\')"><img src="fdel.png" alt="del"></a><td>';
			window.s+='</tr>';
		}
	});

	s+='</table>';
	document.getElementById('divlog').innerHTML=s;
}

function log(html) {
	document.getElementById('log').innerHTML = html;
}
function endUp(){
	if(window.r!==undefined){
		if(window.r.response=="") {
			setTimeout(endUp, 100);
			return;
		}
	}
	window.fcnt--;
	if(window.fcnt>0){
		inpFilePtr();
	}else{
		rddir(window.curDir);	
		window.fileToUp.files=null; 
		document.getElementById('btnUpload').innerHTML='upload';
	}
}
fileToUp = document.getElementById("fileToUp");
function inpFilePtr() {
	var cf=window.fileToUp.files[window.fileToUp.files.length-window.fcnt];
	document.getElementById('btnUpload').innerHTML=cf.name+'...';
	window.r = new XMLHttpRequest();
	window.r.open("PUT", to866(((window.curDir=='')?'':(window.curDir+'/'))+cf.name), true);
	window.r.upload.onprogress = function(event) {
		document.getElementById('btnUpload').innerHTML=cf.name+' '+event.loaded + '/' + event.total;}
	window.r.upload.onload = endUp;
	window.r.upload.onerror = function(event) { 
		inpFilePtr();}
	window.r.send(cf);
}
fcnt=0;
fileToUp.oninput = function(){
	window.fcnt=window.fileToUp.files.length;
    if(window.fcnt<=0) return;
	inpFilePtr();
};
log('status');
rddir('');

