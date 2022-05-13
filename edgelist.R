token_df=read.csv('C:/Users/user/Desktop/social_media/token_df.csv',encoding = 'UTF-8')


########### text preprocessing
token_df$noun = gsub("\\[","",token_df$noun)
token_df$noun = gsub("\\]","",token_df$noun)
token_df$noun = gsub(" ","",token_df$noun)
token_df$noun = gsub("[A-z]","",token_df$noun)
token_df$noun = gsub("\\.","",token_df$noun)
#crawling keyword '��','����','��' delete
token_df$noun = gsub("��","",token_df$noun)
token_df$noun = gsub("����","",token_df$noun)
token_df$noun = gsub("��","",token_df$noun)
token_df$noun = gsub("'","",token_df$noun)

data_noun = data.table(token_df$noun)
post_noun = apply(data_noun, 1, function(x){strsplit(x, split = ',')})

for(i in 1:length(post_noun)){
  post_noun[[i]]$V1=post_noun[[i]]$V1[-which(post_noun[[i]]$V1=="")]
}


########## ��ü �ܾ� �� �� ��� �� �ҿ��, ���Ǿ� ó��
count=data.frame()
for(i in 1:length(post_noun)){
  count=rbind(count,as.matrix(post_noun[[i]]$V1))
}

freq=data.frame(sort(table(count),decreasing = T))
write.csv(freq,'C:/Users/user/Desktop/social_media/total_freq.csv')


#���Ǿ� ó��
token_df$noun = gsub("��","���",token_df$noun)
token_df$noun = gsub("����","���",token_df$noun)
token_df$noun = gsub("�����","���",token_df$noun)
token_df$noun = gsub("�Ƶ�","���",token_df$noun)
token_df$noun = gsub("���̵�","���",token_df$noun)
token_df$noun = gsub("��","����",token_df$noun)
token_df$noun = gsub("�ڵ���","����",token_df$noun)
token_df$noun = gsub("��Ӵ�","����",token_df$noun)
token_df$noun = gsub("��Ӵ�","����",token_df$noun)
token_df$noun = gsub("�ƹ���","�ƺ�",token_df$noun)
token_df$noun = gsub("�ƹ���","�ƺ�",token_df$noun)
token_df$noun = gsub("����","�б�",token_df$noun)
token_df$noun = gsub("�߸�","����",token_df$noun)
token_df$noun = gsub("����","����",token_df$noun)

data_noun = data.table(token_df$noun)
post_noun = apply(data_noun, 1, function(x){strsplit(x, split = ',')})

for(i in 1:length(post_noun)){
  post_noun[[i]]$V1=post_noun[[i]]$V1[-which(post_noun[[i]]$V1=="")]
}


#�ҿ�� ó��('��','��'�� ������ �� ���� �ܾ�)
for(i in 1:length(post_noun)){
  idx=0
  if(length(which(nchar(post_noun[[i]]$V1)<=1))!=0){
    idx=which(nchar(post_noun[[i]]$V1)<=1)
    if(length(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="��"))!=0)
      idx[which(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="��") %in% idx)]
    else if(length(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="��"))!=0)
      idx[which(which(post_noun[[i]]$V1[which(nchar(post_noun[[i]]$V1)<=1)]=="��") %in% idx)]
    else
      post_noun[[i]]$V1=post_noun[[i]]$V1[-idx]
  }
}


########## �ܾ ���� �� ����
for(i in 1:length(post_noun)){
  if(length(post_noun[[i]]$V1)==0)
}
  
length(post_noun[[1]]$V1)


########## convert to edgelist 
edgelist = data.frame(matrix(ncol=2, nrow=0))

for (i in 1:length(post_noun)) {
  print(round(i/length(post_noun)*100,2)) #���� �ۼ�Ʈ Ȯ��
  temp=unique(post_noun[[i]]$V1)
  if (length(temp)<=1) next
  else edgelist = rbind(edgelist, combinations(length(temp),2,temp))
}
#combination : ��� ���� ���(���⼺�� ���� ��Ʈ��ũ�� ������ ��� ���տ� ���ؼ��� �м���)
#combination�� ���� : To use values of n above about 45

write.csv(edgelist,'C:/Users/user/Desktop/social_media/edgelist_noun.csv')
#edgelist ����


####################����ġ�� �ο����� ���� ��Ʈ��ũ �׸���
edgelist_noun=read.csv('C:\\Users\\user\\Desktop\\social_media\\edgelist_noun.csv')

edgelist_count=data.table(edgelist_noun)[,.N,c('V1','V2')]
count_over = subset(edgelist_count, edgelist_count$N>=6)

graph = graph.edgelist(as.matrix(count_over[,c(1,2)]),directed = F)
plot(graph, layout= layout_nicely, vertex.shape='circle', vertex.size=3, vertex.label=NA)


####################����ġ�� �ο��� ��Ʈ��ũ �м�
library(plyr)
edgelist_noun=read.csv('C:\\Users\\user\\Desktop\\social_media\\edgelist_noun.csv')

edgelist_count=data.table(edgelist_noun)[,.N,c('V1','V2')]
edgelist_count_1 = subset(edgelist_count, edgelist_count$N>=6)

# ��Ʈ��ũ ����
graph = graph.edgelist(as.matrix(edgelist_count_1[,c(1,2)]),directed = F)
w=edgelist_count_1$N
E(graph)$weight= w
# plot(graph, layout= layout_nicely, vertex.shape='circle', vertex.size=2)
plot(graph,vertex.size=2, vertex.label=NA)


# �е�
round(graph.density(graph),4)

# ���̼�
round(transitivity(graph),4)

# �ִܰŸ� �󵵿� ������
path.length.hist(graph)$res
round(path.length.hist(graph)$res/sum(path.length.hist(graph)$res),3)


# �����߽ɼ� ���� 2
closeness.2.out <- function(net,n){
  D <- shortest.paths(net, mode='out')
  diag(D) <- Inf
  return(apply(1/D,1,sum)/(n-1))
}
closeness_ori_2 = closeness.2.out(graph,length(V(graph))) # ���� 2
closeness_ori_2 = data.table(closeness_ori_2, rownames=names(closeness_ori_2))
arrange(closeness_ori_2,desc(closeness_ori_2))[1:10]


# ����ġ�� �ݿ��� ���ἱ ��
w_sum=graph.strength(graph)
w_sum=data.table(w_sum, rownames=names(w_sum))
arrange(w_sum,desc(w_sum))[1:10]


# �������� �߽ɼ�
evcent_center = evcent(graph, scale=F)$vector
evcent_center = data.table(evcent_center, rownames=names(evcent_center))
arrange(evcent_center,desc(evcent_center))[1:10]


# ������Ʈ
cluster_ori = clusters(graph)
cluster_ori$no #���� ����
table(cluster_ori$csize) #������ ũ�� ����