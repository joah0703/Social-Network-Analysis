library(igraph)
setwd('C:\\Users\\user\\Desktop\\social_media')

# Python���� ������ edgelist �ҷ�����
edgelist=read.csv('edgelist.csv', encoding='UTF-8')
edgelist=as.matrix(edgelist[,c(3,4)])

A=graph.edgelist(edgelist)

# 134���� ������Ʈ �ľ�
clusters.A=clusters(A)
clusters.A$no
table(clusters.A$csize)
comps <- components(A)$membership
colbar <- rainbow(max(comps)+1)
V(A)$color <- colbar[comps+1]
V(A)$label.cex=0.7
plot(A, layout=layout_nicely, vertex.size=3,edge.width= 1, edge.arrow.size= 0.2,
     edge.color='dark gray')

# 123�� ������Ʈ�� �и�
B = induced_subgraph(A, which(clusters.A$membership == 1))
V(B)$label.cex=0.7
plot(B, layout=layout_nicely, vertex.size=3, edge.width= 1, edge.arrow.size= 0.2,
     edge.color='dark gray')

# ��Ʈ��ũ �е�
round(graph.density(B),3)

# �ִܰŸ� ��ǥ�� ������
path.length.hist(B)$res
round(path.length.hist(B)$res/sum(path.length.hist(B)$res),3)

# ���̼� (ģ���� ģ���� �� ģ��)
round(transitivity(B),3)

# ��ȣ�� (���ȷο� ����)
round(reciprocity(B),3)

# ���� �߽ɼ� Type 2
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

# �߰� �߽ɼ�
round(betweenness(B),3)

## Last. �� �߽ɼ� ��� ��� ����
# ������Ʈ 1�� ���ϴ� ��� ��ȣ ����
all=c(1:134)
component_num=clusters.A$membership
table=cbind(all, component_num)
component_1=subset(table, component_num==1)

# 4�� �߽ɼ� column ����
centrality_table=data.frame(num=component_1[,1])
centrality_table$In=round(closeness.2.in(B, 123),3)
centrality_table$Out=round(closeness.2.out(B, 123),3)
centrality_table$pagerank=round(page.rank(B)$vector,4)
centrality_table$betweeness=round(betweenness(B),3)

# ����ȣ�� �̿��� ����� ������ ����
retweet_sum=read.csv('retweet_sum.csv')
retweet_sum$num=1:nrow(retweet_sum)
centrality_table=merge(retweet_sum, centrality_table)
str(centrality_table)