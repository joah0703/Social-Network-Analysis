library(igraph)
setwd('C:\\Users\\user\\Desktop\\social_media')

# Python에서 생성한 edgelist 불러오기
edgelist=read.csv('edgelist.csv', encoding='UTF-8')
edgelist=as.matrix(edgelist[,c(3,4)])

A=graph.edgelist(edgelist)

# 134명의 컴포넌트 파악
clusters.A=clusters(A)
clusters.A$no
table(clusters.A$csize)
comps <- components(A)$membership
colbar <- rainbow(max(comps)+1)
V(A)$color <- colbar[comps+1]
V(A)$label.cex=0.7
plot(A, layout=layout_nicely, vertex.size=3,edge.width= 1, edge.arrow.size= 0.2,
     edge.color='dark gray')

# 123명 컴포넌트만 분리
B = induced_subgraph(A, which(clusters.A$membership == 1))
V(B)$label.cex=0.7
plot(B, layout=layout_nicely, vertex.size=3, edge.width= 1, edge.arrow.size= 0.2,
     edge.color='dark gray')

# 네트워크 밀도
round(graph.density(B),3)

# 최단거리 빈도표와 상대비율
path.length.hist(B)$res
round(path.length.hist(B)$res/sum(path.length.hist(B)$res),3)

# 추이성 (친구의 친구가 내 친구)
round(transitivity(B),3)

# 상호성 (맞팔로우 관계)
round(reciprocity(B),3)

# 근접 중심성 Type 2
closeness.2.in=function(net, n){
  D=shortest.paths(net, mode='in')
  diag(D)=Inf
  return(apply(1/D,1,sum)/(n-1))
}
round(closeness.2.in(B, 123),3)

closeness.2.out=function(net, n){
  D=shortest.paths(net, mode='out')
  diag(D)=Inf
  return(apply(1/D,1,sum)/(n-1))
}
round(closeness.2.out(B, 123),3)

# 중개 중심성
round(betweenness(B),3)

## Last. 각 중심성 계산 결과 통합
# 컴포넌트 1에 속하는 노드 번호 추출
all=c(1:134)
component_num=clusters.A$membership
table=cbind(all, component_num)
component_1=subset(table, component_num==1)

# 4개 중심성 column 생성
centrality_table=data.frame(num=component_1[,1])
centrality_table$In=round(closeness.2.in(B, 123),3)
centrality_table$Out=round(closeness.2.out(B, 123),3)
centrality_table$pagerank=round(page.rank(B)$vector,4)
centrality_table$betweeness=round(betweenness(B),3)

# 노드번호를 이용해 사용자 정보와 결합
retweet_sum=read.csv('retweet_sum.csv')
retweet_sum$num=1:nrow(retweet_sum)
centrality_table=merge(retweet_sum, centrality_table)
str(centrality_table)
