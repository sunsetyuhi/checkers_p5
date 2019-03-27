//初期設定
void startPosition() {
  x0=y0=x1=y1=0;
  jpos[0]=jpos[1]=0;
  bw=1; //手番は白から
  move=0;
  multiJump = false;
  
  //駒の配置
  for (int i=0; i<=9; i++){
    for (int j=0; j<=9; j++) {
      /*if((i==1&&j==2) || (i==2&&j==1)){board[i][j]=2;}  //終盤テスト用
      else if(i==1&&j==4){board[i][j]=2;}  //3vs2
      else if(i==7&&j==6){board[i][j]=-2;}
      else if(i==7&&j==4){board[i][j]=-2;}  //3vs2*/
      
      if (i==0||j==0||i==9||j==9) {board[i][j]=3;}  //外縁は3
      else if (6<=j && (i+j)%2==1){board[i][j]=1;}  //白は1
      else if (j<=3 && (i+j)%2==1){board[i][j]=-1;}  //黒は-1*/
      else {board[i][j]=0;}  //空のマスは0
    }
  }
}

//盤面の描画
void showBoard() {
  //盤面(背景とグリッド)を描画
  background(230, 170, 120);
  noStroke();
  rectMode(CORNER);
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      if ((i+j)%2 == 0) fill(240, 190, 150);  //ベージュ
      else {fill(210, 130, 70);}  //茶色
      rect((i-1)*side, (j-1)*side, side, side);
    }
  }
  
  
  //盤の上下が逆の時
  //if(flip==-1){pushMatrix();  rotate(PI);  translate(-8*side,-8*side);}
  
  //駒を描画
  numW=numB=0; //両者の石数を数える
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      int p=i,q=j;
      if(flip==-1){p=9-i;  q=9-j;}
      
      //駒の描画
      if (board[i][j]>=1) {  //w piece
        noStroke();  fill(255);
        ellipse(p*side -side/2, q*side -side/2, 0.9*side, 0.9*side);
        numW++;
        if (board[i][j]==2){  //king
          fill(0);
          ellipse(p*side -side/2, q*side -side/2, side/2, side/2);
        }
      }
      else if (board[i][j]<=-1) {  //b piece
        noStroke();  fill(0);
        ellipse(p*side -side/2, q*side -side/2, 0.9*side, 0.9*side);
        numB++;
        if (board[i][j]==-2){  //king
          fill(255);
          ellipse(p*side -side/2, q*side -side/2, side/2, side/2);
        }
      }
      
      //選択した駒の強調
      if(turn==-1){
        noStroke();
        if (i==x0 && j==y0 && board[i][j]!=0) {  //選択中のマス
          fill(255, 0, 0, 100);
          rect((p-1)*side, (q-1)*side, side, side);
        }
        else if (validMove(x0,y0, i,j)) {  //動ける先のマスを強調
          if(bw==-1){fill(0, 0, 0, 200);}
          else if(bw==1){fill(255, 255, 255, 200);}
          ellipse((p-1)*side +side/2, (q-1)*side +side/2, side/3, side/3);
        }
      }
      
      //マスの番号
      if(board[i][j]==0){fill(0, 0, 255);}
      else if(board[i][j]>=1){fill(0);}
      else if(board[i][j]<=-1){fill(255);}
      textSize(0.25*side);
      textAlign(CENTER,CENTER);
      if((i+j)%2==1){
        int k=ceil(float(9-i)/2) +4*(9-j-1);  //番号
        text(k, p*side-0.2*side, q*side-0.2*side);
      }//*/
    }
  }
  
  //COMの手
  if(turn!=1){
    int bp=bk,bq=bl, br=bi,bs=bj;
    if(flip==-1){bp=9-bk;bq=9-bl;  br=9-bi;bs=9-bj;}
    
    fill(255, 255, 0, 100);  noStroke();
    rect((bp-1)*side, (bq-1)*side, side, side);  //移動前のマスを黄
    
    fill(0, 255, 255, 100);  noStroke();
    rect((br-1)*side, (bs-1)*side, side, side);  //移動後のマスを青緑
  }
  
  //if(flip==-1){popMatrix();}
  
  
  //手番を表示(右上)
  textSize(side/2);
  textAlign(CENTER);
  fill(255,0,0);
  text("TURN", 9*side,side/2);
  stroke(0);
  rectMode(CENTER);
  noFill();
  rect(9*side,side, side,side); //外枠
  noStroke();
  if (bw==1) {fill(255);} //白番
  else {fill(0);} //黒番
  ellipse(9*side,side, side,side);
  
  //戻るボタン(右中)
  rectMode(CORNER);
  fill(255,255,0);
  rect(8.3*side,3.5*side, 1.4*side,0.7*side); //外枠
  textSize(side/2.5);
  textAlign(CENTER);
  fill(0);
  text("BACK", 9*side,4*side);
  
  //flip
  rectMode(CORNER);
  fill(255,255,0);
  rect(8.3*side,4.5*side, 1.4*side,0.7*side); //外枠
  textSize(side/2.5);
  textAlign(CENTER);
  fill(0);
  text("FLIP", 9*side,5*side);
  
  //両者の石の数(右下)
  textSize(side*0.35);
  textAlign(CENTER,CENTER);
  fill(255);
  text("WHITE:"+numW, 9*side,height-side);
  fill(0);
  text("BLACK:"+numB, 9*side,height-side/2);
}
