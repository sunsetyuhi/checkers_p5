//着手した駒の位置を評価
float posMoves(int k,int l,int i,int j){
  float dn=0;
  
  //相手の駒を取ったら高評価
  //if(abs(i-k)==2){dn+=20;}
  
  //kingになる手は高評価
  //if(bw==1 && j==1){dn+=10;}
  //else if(bw==-1 && j==8){dn+=10;}
  
  //中央に動かす手は高評価
  //if(2<=i&&i<=7 && 3<=j&&j<=6){dn+=30;}
  
  return 1.0*dn;
}

//駒数を評価
float numPieces() {
  float dn = 0;
  float dnw=0, dnb=0;
  float dp=10, dk=20;
  
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if(board[k][l]==2){dnw += dk;}  //wking
      else if(board[k][l]==1){dnw += dp;}  //wpawn
      
      else if(board[k][l]==-2){dnb += dk;}  //bking
      else if(board[k][l]==-1){dnb += dp;}  //bpawn*/
    }
  }
  dn = -150*bw*(exp(-0.01*dnw) -exp(-0.01*dnb));
  //dn = bw*(dnw -dnb);
  //if(dn!=0){dn = 20*dn/abs(dn) *sqrt(abs(dn));}
  
  return 5.0*dn;
}

//駒の配置を評価
float position() {
  float dn=0.0, dnp=0.0;
  float dnw=0.0, dnb=0.0;
  
  //駒数を数える
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if(board[k][l]==1 || board[k][l]==2){dnw++;}
      else if(board[k][l]==-1 || board[k][l]==-2){dnb++;}
    }
  }
  dnp = dnw +dnb;
  
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      //盤中央にある駒を評価
      //if(3<=k&&k<=6 && 3<=l&&l<=6 && board[k][l]!=0){dn += 1.0*bw*board[k][l];}
      //if(3<=k&&k<=6 && 3<=l&&l<=6 && abs(board[k][l])==1){dn += 1.0*bw*board[k][l];}  //pawn
      if(3<=k&&k<=6 && 3<=l&&l<=6 && abs(board[k][l])==2){dn += 2.0*bw*board[k][l];}  //king
      
      //シングルコーナーのキングは低評価（駒数が多いほど大きく評価？）
      if((7<=k&&l<=2 || k<=2&&7<=l) && abs(board[k][l])==2){dn -= 3.0*bw*board[k][l];}
      
      //キングの周囲の評価（自分のキングの周囲に相手駒がいれば高評価）
      int area=3;
      if(abs(board[k][l])==3){
        for(int p=k-area;p<=k+area;p++){
          for(int q=l-area;q<=l+area;q++){
            if(1<=p&&p<=8 && 1<=q&&q<=8){  //盤内を見る
              //キングと異なる色の駒があった時に評価（高評価しすぎると駒を取らない？）
              if(board[k][l]*board[p][q]<0){dn += -1.0*bw*board[p][q];}
              
              //キングと異なる色のポーンがあった時に評価
              //if(board[k][l]*board[p][q]==-2){dn += -1.0*bw*board[p][q];}
            }
          }
        }
      }
      
      //最下段にあるポーンを評価（駒数が少ないほど小さく評価）
      if(3<=k&&l==8 && board[k][l]==1){dn += 4.0*sqrt(dnw)*bw*board[k][l];}  //白
      //else if(k==1&&l==8 && board[k][l]==1){dn += 1.0*sqrt(dnw)*bw*board[k][l];}  //白シングルコーナー
      //else if(k==8&&l==7 && board[k][l]==1){dn += 1.0*sqrt(dnw)*bw*board[k][l];}  //白ダブルコーナー
      else if(k<=6&&l==1 && board[k][l]==-1){dn += 4.0*sqrt(dnb)*bw*board[k][l];}  //黒
      //else if(k==8&&l==1 && board[k][l]==-1){dn += 1.0*sqrt(dnb)*bw*board[k][l];}  //黒シングルコーナー
      //else if(k==1&&l==2 && board[k][l]==-1){dn += 1.0*sqrt(dnb)*bw*board[k][l];}  //黒ダブルコーナー
    }
  }
  
  return 1.0*dn;
}

//両者の隣接した駒のペア数
float numTandems() {
  float dn = 0.0;
  
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      if(board[k][l]!=0){  //マスが空でない時、隣が同色の駒なら評価
        if(k+1<=8 && l+1<=8){  //右上方向
          if(0<board[k][l]*board[k+1][l+1]){dn += 1.0*bw*board[k][l]/abs(board[k][l]);}
        }
        if(k+1<=8 && 1<=l-1){  //右下方向
          if(0<board[k][l]*board[k+1][l-1]){dn += 1.0*bw*board[k][l]/abs(board[k][l]);}
        }
      }
      
      //pawn同士のみ
      /*if(abs(board[k][l])==1){  //pawnの隣が同色のポーンなら評価
        if(k+1<=8 && l+1<=8 && abs(board[k+1][l+1])==1){  //右上方向
          if(0<board[k][l]*board[k+1][l+1]){dn += bw*board[k][l];}
        }
        if(k+1<=8 && 1<=l-1 && abs(board[k+1][l-1])==1){  //右下方向
          if(0<board[k][l]*board[k+1][l-1]){dn += bw*board[k][l];}
        }
      }//*/
    }
  }
  
  return 1.0*dn;
}

//両者の合法手数を評価（次に相手に取られる手は低評価？）
float numMoves() {
  float dn=0;
  boolean multiJump_tmp=multiJump, mustJump_tmp=mustJump;
  
  //強制飛びの判定を一旦キャンセル
  multiJump=mustJump=false;
  
  for(int o=0;o<=1;o++){ //両者を評価(自分→相手)
    float dm=0;
    
    //(k,l)から指せる手を数える
    for (int k=1; k<=8; k++) {
      for (int l=1; l<=8; l++) {
        float weight = 1.0;
        //if(abs(board[k][l])==2){weight = 2.0;}  //kingの合法手なら高評価
        
        //1マス進む場合
        if (validMove(k,l, k+1,l+1)) {dm += 1.0*weight;}
        else if (validMove(k,l, k+1,l-1)) {dm += 1.0*weight;}
        else if (validMove(k,l, k-1,l+1)) {dm += 1.0*weight;}
        else if (validMove(k,l, k-1,l-1)) {dm += 1.0*weight;}
        
        //2マス進む場合
        else if (validMove(k,l, k+2,l+2)) {dm += 1.0*weight;}
        else if (validMove(k,l, k+2,l-2)) {dm += 1.0*weight;}
        else if (validMove(k,l, k-2,l+2)) {dm += 1.0*weight;}
        else if (validMove(k,l, k-2,l-2)) {dm += 1.0*weight;}
      }
    }
    dm = -100*exp(-0.2*dm);
    //if (dm==1) {dm=-30;} //合法手が1個
    //else if (dm==2) {dm=-5;} //合法手が2個
    
    //自分の評価(o=0)なら加点、相手の評価(o=1)なら減点
    if(o==0){dn+=dm;}  else if(o==1){dn-=dm;}
    
    bw = -bw; //石の色を反転
  }
  
  //強制飛びの判定を元に戻す
  multiJump=multiJump_tmp;
  mustJump=mustJump_tmp;
  
  return 1.0*dn;
}

//tempi差（pawnの進み具合）を見る
float tempi(){
  float dn = 0;
  float dnw=0, dnb=0;
  
  for (int i=1; i<=8; i++) {
    for (int j=1; j<=8; j++) {
      //pawnのtempi
      //if(board[i][j]==1){dnw += (9-j);}  //白
      //else if(board[i][j]==-1){dnb += j;}  //黒
      
      //pawnのtempi（最上段を0基準）
      if(board[i][j]==1){dnw += (9-j)-8;}  //白
      else if(board[i][j]==-1){dnb += j-8;}  //黒
    }
  }
  dn = bw*(dnw -dnb);
  if(dn!=0){dn = dn/abs(dn) *sqrt(abs(0.8*dn));}  //過大評価を平方根で抑制
  //dn = -10 *dn/abs(dn) *exp(-0.01*abs(dn));
  
  return 1.0*dn;
}



//駒の前方に他の駒が無いか(キングを作れるか)を判定
float breakthrough() {
  float dn = 0;
  
  for (int i=1; i<=8; i++) {
    for (int j=1; j<=8; j++) {
      int ri=i, rj=j;
      int flag=0;
      
      if(board[i][j]==1){  //白
        while(flag==0 && 1<=rj){ //空きマスかつ左辺を越えない間
          int s=0;
          while(flag==0 && 1<=ri-s && 1<=rj-s){  //
            if(board[ri-s][rj-s]!=0){flag=1;}  //空きマスでない時
            s++;
          }
          
          if(ri<8){ri=ri+1;  rj=rj-1;}
          if(ri==8){rj=rj-2;}
        }
        
        //if(flag==0){dn += bw*j*board[i][j];}  //駒が底辺に近いほど高評価
        if(flag==0){dn += 2.0*bw*board[i][j];}
      }
      
      else if(board[i][j]==-1){  //黒
        while(flag==0 && rj<=8){
          int s=0;
          while(flag==0 && 1<=ri-s && rj+s<=8){
            if(board[ri-s][rj-s]!=0){flag=1;}  //空きマスでない時
            s++;
          }
          
          if(ri<8){ri=ri+1;  rj=rj+1;}
          if(ri==8){rj=rj+2;}
        }
        
        //if(flag==0){dn += bw*(9-j)*board[i][j];}
        if(flag==0){dn += 2.0*bw*board[i][j];}
      }
      
      //kingの補正
      //if(abs(board[i][j])==2){dn += 4*bw*board[i][j];}
      if(abs(board[i][j])==2){dn += bw*board[i][j];}
    }
  }
  
  return 0.0*dn;
}

//二回飛べる着手を評価
float doubleTakes() {
  float dn = 0;
  
  for(int o=0;o<=1;o++){ //両者を評価(自分→相手)
    int dm=0;
    
    recorder(true); //配置を記録
    for (int k=1; k<=8; k++) {
      for (int l=1; l<=8; l++) {
        for (int i=1; i<=8; i++){
          for (int j=1; j<=8; j++) {
            if (abs(k-i)==2 && abs(l-j)==2 && validMove(k,l, i,j)){ //飛べる手
              movePiece(k,l, i,j); //仮に打つ
              
              if (validMove(i,j, i+2,j+2) || validMove(i,j, i+2,j-2) ||
                  validMove(i,j, i-2,j+2) || validMove(i,j, i-2,j-2)) {dm+=10;}
              
              recorder(false);  //元の盤面に戻す
            }
          }
        }
      }
    }
    
    //自分の評価(o=0)なら加点、相手の評価(o=1)なら減点
    if(o==0){dn+=dm;}  else if(o==1){dn-=dm;}
    
    bw = -bw; //石の色を反転
  }
  
  return 0.0*dn;
}
