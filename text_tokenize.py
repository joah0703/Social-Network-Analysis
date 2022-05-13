import os
import pandas as pd
from pandas import DataFrame
import pickle

os.chdir('C:/Users/user/Desktop/social_media')


#데이터 전처리(매크로, 뉴스 등 의미없는 계정 삭제)
tweet_df = pd.read_csv('twitter_data.csv',encoding='utf-8')
del_names=pd.read_table('del_names.txt',header=None)
#총 255개의 계정 삭제

#의미없는 계정 삭제
del_idx=[]
for i in del_names:
    for j in enumerate(list(tweet_df.username)):
        if i==j[1]:
            del_idx.append(j[0])
            
complete_df=tweet_df[['author_id','username','text']]
complete_df=complete_df.drop(del_idx)
#6010개의 트윗만 남김(author_id, username, text)

DataFrame.to_csv(complete_df, 'complete_df.csv', encoding='utf-8-sig',index=False)
complete_df=pd.read_csv('complete_df.csv')

#%%text tokenize
from nltk.tokenize import word_tokenize
from nltk.tag import pos_tag
from konlpy.tag import Komoran  

komoran=Komoran()

noun=[]
for i in list(complete_df.text):
    noun.append(komoran.nouns(i))

complete_df['noun']=noun
#토큰화 및 명사 추출

token_df=complete_df

del token_df['text']
#R로 읽을 때 text열로 인한 에러 발생 -> 제거하고 진행

DataFrame.to_csv(complete_df, 'token_df.csv', encoding='utf-8-sig',index=False)
complete_df=pd.read_csv('token_df.csv')
