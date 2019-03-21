boolean validMove(int i0, int j0, int i1, int j1) {
  if(i0<1||8<i0 || j0<1||8<j0 || i1<1||8<i1 || j1<1||8<j1) {return false;}  //盤外の手は指せない
  if(board[i0][j0]==0 || board[i1][j1]!=0) {return false;}  //空マスから、または駒があるマスには指せない
  if(multiJump && (i0!=jpos[0] || j0!=jpos[1])) {return false;}  //連続飛びの駒が他にあれば指せない
  if(mustJump && (abs(i1-i0)!=2 || abs(j1-j0)!=2)) {return false;}  //強制飛びの駒が他にあれば指せない

  if(board[i0][j0] == bw) {  //pawn
    //斜め前が空きマスの時
    if(abs(i1-i0)==1 && j1-j0==-bw && board[i1][j1]==0) {return true;}
    
    //行先が斜め2つ上で空、間に相手の駒がある時
    if(abs(i1-i0)==2 && j1-j0==-2*bw && board[i1][j1]==0 && 
      (board[int((i0+i1)/2)][j0-bw]==-bw || board[int((i0+i1)/2)][j0-bw]==-2*bw)){return true;}
  }
  else if(board[i0][j0] == 2*bw) {  //king
    //斜め前後が空きマスの時
    if(abs(i1-i0)==1 && abs(j1-j0)==1 && board[i1][j1]==0) {return true;}
    
    //行先が斜め2つ先で空、間に相手の駒がある時
    if(abs(i1-i0)==2 && abs(j1-j0)==2 && board[i1][j1]==0 &&
      (board[int((i0+i1)/2)][int((j0+j1)/2)]==-bw || board[int((i0+i1)/2)][int((j0+j1)/2)]==-2*bw)){return true;}
  }
  
  return false;
}

void movePiece(int i0, int j0, int i1, int j1) {
  boolean promote = false;
  mustJump = false;  //強制飛び判定をfalseにする
  multiJump = false;  //連続飛び判定をfalseにする
  
  //promote
  if((board[i0][j0]==1 && j1==1) || (board[i0][j0]==-1 && j1==8)) {
    board[i0][j0] = 2*bw;  //ポーンをキングにする
    promote = true;
  }
  
  board[i1][j1] = board[i0][j0];  //move piece
  board[i0][j0] = 0;  //remove original piece
  
  //飛んだ時の処理
  if (abs(i0-i1)==2 && abs(j0-j1)==2) {
    board[(i0+i1)/2][(j0+j1)/2] = 0;  //間の駒を消す
    jpos[0]=i1;  jpos[1]=j1;  //飛んだ先のマスを保存
    
    if (promote==false) {  //駒が成っていない時、続けて飛べるか判定
      if(validMove(i1,j1,i1+2,j1+2) || validMove(i1,j1,i1+2,j1-2) ||
         validMove(i1,j1,i1-2,j1+2) || validMove(i1,j1,i1-2,j1-2)){
        multiJump = true;
      }
    }
  }
  
  //次が強制飛びか判定
  if(multiJump==false){bw = -bw;}  //連続飛びでなければ相手番で考える
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if (validMove(k,l, k+2,l+2)) {mustJump = true;}
      if (validMove(k,l, k+2,l-2)) {mustJump = true;}
      if (validMove(k,l, k-2,l+2)) {mustJump = true;}
      if (validMove(k,l, k-2,l-2)) {mustJump = true;}
    }
  }
  if(multiJump==false){bw = -bw;}
}

//終局判定（合法手がないことを確認）
boolean finish() {
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if(board[k][l]!=0){  //空きマス以外
        if (validMove(k,l, k+1,l+1)) {return false;}
        if (validMove(k,l, k+1,l-1)) {return false;}
        if (validMove(k,l, k-1,l+1)) {return false;}
        if (validMove(k,l, k-1,l-1)) {return false;}
        
        if (validMove(k,l, k+2,l+2)) {return false;}
        if (validMove(k,l, k+2,l-2)) {return false;}
        if (validMove(k,l, k-2,l+2)) {return false;}
        if (validMove(k,l, k-2,l-2)) {return false;}
      }
    }
  }
  return true;
}

//引き分け判定
boolean drawCheck() {
  int draw_min=3, draw_mid=50, draw_max=1000;
  int numW_old=0,numB_old=0, numW_now=0,numB_now=0;
  int m=move-1, sameState=1;
  
  //同局面がdraw_min回現れたら引き分け
  while (1<m) {
    int same_flag=1, king_flag=0;
    
    for (int k=1; k<=8; k++) {
      for (int l=1; l<=8; l++) {
        //現局面と異なる局面ならばフラグを消す
        if(board_rec[m][k][l]!=board[k][l]){same_flag=0;}
        
        //kingがあったらフラグを立てる
        if(abs(board_rec[m][k][l])==2){king_flag=1;}
      }
    }
    
    if(same_flag==1){sameState++;}  //同局面なら数える
    if(sameState==draw_min){return true;}
    
    m--;
    
    //kingが1枚もない局面以前は同形反復が起きないと考えられる
    if(king_flag==0){m=0;}
  }
	
  //両者がdraw_mid手(合計2*draw_mid手)指す間、駒数に変化なければ引き分け
  /*if(2.0*draw_mid<=move){
    for (int k=1;k<=8;k++){  //draw_min手前の駒数を調べる
      for (int l=1;l<=8;l++) {
        if(1<=board_rec[move-draw_mid][k][l]){numW_old++;}
        if(board_rec[move-draw_mid][k][l]<=-1){numB_old++;}
      }
    }
    for (int k=1;k<=8;k++){  //現在の駒数を調べる
      for (int l=1;l<=8;l++) {
        if(1<=board[k][l]){numW_now++;}
        if(board[k][l]<=-1){numB_now++;}
      }
    }
    if(numW_old==numW_now && numB_old==numB_now){return true;}
  }//*/
  
  //手数がdraw_max手になったら引き分け
  if(draw_max<=move){return true;}
  
  return false;
}

void recorder(boolean inout) {
  if(inout==true){  //記録
    for (int k=1;k<=8;k++){ //駒の配置
      for (int l=1;l<=8;l++) {board_rec[move][k][l] = board[k][l];}
    }
    bw_rec[move]=bw;
    
    mustJump_rec[move]=mustJump;  //強制飛びの判定
    multiJump_rec[move]=multiJump;  //連続飛びの判定
    jpos_rec[move][0]=jpos[0];  jpos_rec[move][1]=jpos[1];
  }
  else if(inout==false){  //呼び出し
    for (int k=1;k<=8;k++) { //駒の配置
      for (int l=1;l<=8;l++) {board[k][l] = board_rec[move][k][l];}
    }
    bw=bw_rec[move];
    
    mustJump=mustJump_rec[move];  //強制飛びの判定
    multiJump=multiJump_rec[move];  //連続飛びの判定
    jpos[0]=jpos_rec[move][0];  jpos[1]=jpos_rec[move][1];
  }
}
