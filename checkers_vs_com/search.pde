float opening=2.0, mid_d=5.0, end_num=3.0, end_d=7.0; //5,3,7.
float score_max=9000;
int bk=0,bl=0, bi=0,bj=0;  //AI move

void com() {
  float n=0, max=-2*score_max;
  int place=0; //打てるか判定
  node_count=0;
  
  if (turn==1) {  //手番がAI(1)の時
    recorder(true);  //配置を記録
    
    for (int k=1; k<=8; k++) {
      for (int l=1; l<=8; l++) {
        for (int i=-2; i<=2; i++) {
          for (int j=-2; j<=2; j++) {
            if (validMove(k,l, k+i,l+j)) {
              float m = posMoves(k,l, k+i,l+j);
              
              movePiece(k,l, k+i,l+j);
              move++;
              bw = -bw; //石の色を反転
              place=1;
              
              if(move <= opening) {  //opening手目まではバラつかせる
                n = random(1);
              }
              else if(end_num < numW+numB) {  //残りend_num駒まではmid_d手読み
                n = -negaalpha(mid_d-1.0, -score_max,score_max)
        		          +m -position() -numTandems() -numMoves() +random(1);
              }
              else{
                //n = -negaalpha(end_d -0.5*(numW+numB) -1.0, -score_max,score_max)
                n = -negaalpha(end_d-1.0, -score_max,score_max)
		                  +m -position() -numTandems() -numMoves() +random(1);
              }
              int mv0 = ceil(float(9-k)/2) +4*(9-l-1);
              int mv1 = ceil(float(9-(k+i))/2) +4*(9-(l+j)-1);
              print(mv0 +">" +mv1 +"," +nfs(round(n),4) +";   ");
              
              if (max<n) {
                max = n;
                bk=k;  bl=l;
                bi=k+i;  bj=l+j;
              }
              
              move--;
              recorder(false);  //元の盤面に戻す
            }
          }
        }
      }
    }
    
    if (place==1) { //打てれば実行
      println("");
      
      movePiece(bk, bl, bi, bj);
      move++;
      
      int mv0 = ceil(float(9-bk)/2) +4*(9-bl-1);
      int mv1 = ceil(float(9-bi)/2) +4*(9-bj-1);
      println(">> mv" +nf(move,3) +",COM" +mv0 +">" +mv1 +";  values = " +nfs(int(max),4) +";  nodes = " +node_count +";   ");
      println("");
      
      //続けて飛べないなら手番を変える
      if (multiJump==false) {
        bw = -bw;
        turn = -turn;
      }
      
      showBoard();
      bk=0;bl=0;  bi=0;bj=0;
    }
  }
}

float mid_eval(){
  float n=0;
  n = numPieces() +numTandems() +position();
  return n;
}

int node_count=0; //探索した局面数を数える
float negaalpha(float depth,float a,float b){ //ネガアルファ法
  float n=-score_max,value, w1;
  int r=0,w2, place=0; //打てるか判定
  float[] v=new float[50]; //並び替え用
  int[] p0=new int[50],q0=new int[50];
  int[] p1=new int[50],q1=new int[50];
  
  //合法手が無ければ負け
  if(multiJump==false && finish()) {node_count++;  return -score_max *(depth/mid_d +1)/2;}
  
  //引き分け
  if(drawCheck()) {node_count++;  return (numPieces() +tempi())/5.0;}
  
  //深さ制限に達したら評価値を返す
  if(depth<=0) {node_count++;  return mid_d*(numPieces() +tempi());}
  
  //相手に打てる所があれば、1手読みで仮探索
  recorder(true); //石の配置を記録
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      for (int i=-2; i<=2; i++) {  //-2<=i<=2
        for (int j=-2; j<=2; j++) {
          if ((k+l)%2==1 && validMove(k,l, k+i,l+j)) {
            movePiece(k,l, k+i,l+j);
            
            r++;
            p0[r]=k;  q0[r]=l;
            p1[r]=k+i;  q1[r]=l+j;
            
            v[r] = tempi() +position() +numMoves();
            
            recorder(false); //1手前の局面に戻す
          }
        }
      }
    }
  }
  
  //評価の大きい順にMove ordering(バブルソート)
  for (int s=1; s<=r-1; s++){
    for (int t=r; s<=t-1; t--){
      if(v[t-1]<v[t]){
        w1=v[t];  v[t]=v[t-1];  v[t-1]=w1;
        w2=p0[t];  p0[t]=p0[t-1];  p0[t-1]=w2;
        w2=q0[t];  q0[t]=q0[t-1];  q0[t-1]=w2;
        w2=p1[t];  p1[t]=p1[t-1];  p1[t-1]=w2;
        w2=q1[t];  q1[t]=q1[t-1];  q1[t-1]=w2;
      }
    }
  }
  
  //最適手を再帰で探索
  for (int s=1;s<=r;s++){
    int u0=p0[s], v0=q0[s], u1=p1[s], v1=q1[s];  //移動前→移動先
    
    //float m = posMoves(u0,v0, u1,v1);
    
    movePiece(u0,v0, u1,v1);
    
    float dd = 1.0;
    if(r<=5){dd = float(r-1)/float(r);}  //合法手数に応じて延長
    
    //隣が相手の駒なら延長
    else if(board[u1+1][v1+1]==-bw || board[u1+1][v1+1]==-2*bw){dd=0.6;}
    else if(board[u1+1][v1-1]==-bw || board[u1+1][v1-1]==-2*bw){dd=0.6;}
    else if(board[u1-1][v1+1]==-bw || board[u1-1][v1+1]==-2*bw){dd=0.6;}
    else if(board[u1-1][v1-1]==-bw || board[u1-1][v1-1]==-2*bw){dd=0.6;}
    
    if(abs(u1-u0)==2){dd=0.3;}  //強制飛びの時は延長
    
    move++;
    bw = -bw; //石の色を反転
    place=1; //打てると判定

    //相手の手を再帰で評価(自分はα<value<β、相手は-β<-value<-α)
    value = -negaalpha(depth-dd,-b,-a)
              -position() -numTandems() -numMoves();
              //+m -position() -numTandems() -numMoves();
    
    move--;
    recorder(false); //1手前の局面に戻す
    
    if (b<=value) {return value;} //上限値以上なら探索打ち切り
    if (n<value) { //最大値を超えたら置換、下限値も更新
      n = value;
      a = max(a,n);
    }
  }
  
  //相手に合法手が無ければ負け
  //if(place==0 && multiJump==false) {return -score_max;}
  
  //自分の手番で続けて飛べるなら、自分の手を再帰で評価
  if(place==0 && multiJump==true){
    bw=-bw;
    value = -negaalpha(depth-0.3,-b,-a);
    bw=-bw;
    return value;
  }
  
  return n;
}
