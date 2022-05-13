token_df=read.csv('C:/Users/user/Desktop/social_media/token_df.csv',encoding = 'UTF-8')


########### text preprocessing
token_df$noun = gsub("\\[","",token_df$noun)
token_df$noun = gsub("\\]","",token_df$noun)
token_df$noun = gsub(" ","",token_df$noun)
token_df$noun = gsub("[A-z]","",token_df$noun)
token_df$noun = gsub("\\.","",token_df$noun)
#crawling keyword '민','식이','법' delete
token_df$noun = gsub("민","",token_df$noun)
token_df$noun = gsub("식이","",token_df$noun)
token_df$noun = gsub("법","",token_df$noun)
token_df$noun = gsub("'","",token_df$noun)

data_noun = data.table(token_df$noun)
post_noun = apply(data_noun, 1, function(x){strsplit(x, split = ',')})

for(i in 1:length(post_noun)){
  post_noun[[i]]$V1=post_noun[[i]]$V1[-which(post_noun[[i]]$V1=="")]
}


########## 전체 단어 빈도 수 계산 및 불용어, 동의어 처리
count=data.frame()
for(i in 1:length(post_noun)){
  count=rbind(count,as.matrix(post_noun[[i]]$V1))
}

freq=data.frame(sort(table(count),decreasing = T))
write.csv(freq,'C:/Users/user/Desktop/social_media/total_freq.csv')


#동의어 처리
token_df$noun = gsub("애","어린이",token_df$noun)
token_df$noun = gsub("아이","어린이",token_df$noun)
token_df$noun = gsub("어린아이","어린이",token_df$noun)
token_df$noun = gsub("아동","어린이",token_df$noun)
token_df$noun = gsub("아이들","어린이",token_df$noun)
token_df$noun = gsub("차","차량",token_df$noun)
token_df$noun = gsub("자동차","차량",token_df$noun)
token_df$noun = gsub("어머님","엄마",token_df$noun)
token_df$noun = gsub("어머니","엄마",token_df$noun)
token_df$noun = gsub("아버지","아빠",token_df$noun)
token_df$noun = gsub("아버님","아빠",token_df$noun)
token_df$noun = gsub("스쿨","학교",token_df$noun)
token_df$noun = gsub("잘못","과실",token_df$noun)
token_df$noun = gsub("조심","주의",token_df$noun)

data_noun = data.table(token_df$noun)
post_noun = apply(data_noun, 1, function(x){strsplit(x, split = ',')})

for(i in 1:length(post_noun)){
  post_noun[[i]]$V1=post_noun[[i]]$V1[-which(post_noun[[i]]$V1=="")]
}


#불용어 처리('술','욕'을 제외한 한 글자 단어)
for(i in 1:length(post_noun)){
  idx=0
  if(length(which(nchar(post_noun[[i]]$V1)<=1))!=0){
    idx=which(nchar(post_noun[[i]]$V1)<=1)
    if(length(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="술"))!=0)
      idx[which(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="술") %in% idx)]
    else if(length(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="욕"))!=0)
      idx[which(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="욕") %in% idx)]
    else
      post_noun[[i]]$V1=post_noun[[i]]$V1[-idx]
  }
}


########## 단어가 없는 글 제거
for(i in 1:length(post_noun)){
  if(length(post_noun[[i]]$V1)==0)
}
  
length(post_noun[[1]]$V1)


########## convert to edgelist 
edgelist = data.frame(matrix(ncol=2, nrow=0))

for (i in 1:length(post_noun)) {
  print(round(i/length(post_noun)*100,2)) #진행 퍼센트 확인
  temp=unique(post_noun[[i]]$V1)
  if (length(temp)<=1) next
  else edgelist = rbind(edgelist, combinations(length(temp),2,temp))
}
#combination : 모든 조합 사용(방향성이 없는 네트워크기 때문에 모든 조합에 대해서만 분석함)
#combination의 조건 : To use values of n above about 45

write.csv(edgelist,'C:/Users/user/Desktop/social_media/edgelist_noun.csv')
#edgelist 생성


####################가중치를 부여하지 않은 네트워크 그리기
edgelist_noun=read.csv('C:\\Users\\user\\Desktop\\social_media\\edgelist_noun.csv')

edgelist_count=data.table(edgelist_noun)[,.N,c('V1','V2')]
count_over = subset(edgelist_count, edgelist_count$N>=6)

graph = graph.edgelist(as.matrix(count_over[,c(1,2)]),directed = F)
plot(graph, layout= layout_nicely, vertex.shape='circle', vertex.size=3, vertex.label=NA)


####################가중치를 부여한 네트워크 분석
library(plyr)
edgelist_noun=read.csv('C:\\Users\\user\\Desktop\\social_media\\edgelist_noun.csv')

edgelist_count=data.table(edgelist_noun)[,.N,c('V1','V2')]
edgelist_count_1 = subset(edgelist_count, edgelist_count$N>=6)

# 네트워크 생성
graph = graph.edgelist(as.matrix(edgelist_count_1[,c(1,2)]),directed = F)
w=edgelist_count_1$N
E(graph)$weight= w
# plot(graph, layout= layout_nicely, vertex.shape='circle', vertex.size=2)
plot(graph,vertex.size=2, vertex.label=NA)


# 밀도
round(graph.density(graph),4)

# 추이성
round(transitivity(graph),4)

# 최단거리 빈도와 상대비율
path.length.hist(graph)$res
round(path.length.hist(graph)$res/sum(path.length.hist(graph)$res),3)


# 근접중심성 정의 2
closeness.2.out <- function(net,n){
  D <- shortest.paths(net, mode='out')
  diag(D) <- Inf
  return(apply(1/D,1,sum)/(n-1))
}
closeness_ori_2 = closeness.2.out(graph,length(V(graph))) # 정의 2
closeness_ori_2 = data.table(closeness_ori_2, rownames=names(closeness_ori_2))
arrange(closeness_ori_2,desc(closeness_ori_2))[1:10]


# 가중치를 반영한 연결선 수
w_sum=graph.strength(graph)
w_sum=data.table(w_sum, rownames=names(w_sum))
arrange(w_sum,desc(w_sum))[1:10]


# 고유벡터 중심성
evcent_center = evcent(graph, scale=F)$vector
evcent_center = data.table(evcent_center, rownames=names(evcent_center))
arrange(evcent_center,desc(evcent_center))[1:10]


# 컴포넌트
cluster_ori = clusters(graph)
cluster_ori$no #군집 개수
table(cluster_ori$csize) #군집의 크기 갯수
