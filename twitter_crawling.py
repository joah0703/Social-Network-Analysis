#####트위터 크롤링
#pip install GetOldTweets3
import GetOldTweets3 as got
import os
import datetime
import time
import pandas as pd
from pandas import DataFrame
import tweepy
import progressbar
import pickle

os.chdir('E:/social_media')


#가져올 기간 설정(days_range)
days_range = []

start = datetime.datetime.strptime("2020-05-16", "%Y-%m-%d")
end = datetime.datetime.strptime("2020-06-01", "%Y-%m-%d")
date_generated = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]

for date in date_generated:
    days_range.append(date.strftime("%Y-%m-%d"))

print("=== 설정된 트윗 수집 기간은 {} 에서 {} 까지 입니다 ===".format(days_range[0], days_range[-1]))
print("=== 총 {}일 간의 데이터 수집 ===".format(len(days_range)))


##keyword가 포함된 트위터 추출
# 수집 기간 맞추기
start_date = days_range[0]
end_date = (datetime.datetime.strptime(days_range[-1], "%Y-%m-%d") 
            + datetime.timedelta(days=1)).strftime("%Y-%m-%d") # setUntil이 끝을 포함하지 않으므로, day + 1

# 트윗 수집 기준 정의
tweetCriteria = got.manager.TweetCriteria().setQuerySearch('민식이법')\
                                           .setSince(start_date)\
                                           .setUntil(end_date)\
                                           .setMaxTweets(-1)

# 수집 with GetOldTweet3
print("Collecting data start.. from {} to {}".format(days_range[0], days_range[-1]))
start_time = time.time()

tweet = got.manager.TweetManager.getTweets(tweetCriteria) #수집

print("Collecting data end.. {0:0.2f} Minutes".format((time.time() - start_time)/60)) #걸린 시간 확인
print("=== Total num of tweets is {} ===".format(len(tweet)))

#2020-03-01 ~ 2020-03-14 / 31 tweets / 0.09 minutes = tweet_result
#2020-03-15 ~ 2020-03-31 / 2249 tweets / 4.42 minutes = tweet_result2
#2020-04-01 ~ 2020-04-15 / 924 tweets / 1.91 minutes = tweet_result3
#2020-04-16 ~ 2020-04-30 / 683 tweets / 1.37 minutes = tweet_result4
#2020-05-01 ~ 2020-05-15 / 1510 tweets / 3.02 minutes = tweet_result5
#2020-05-16 ~ 2020-05-31 / 2078 tweets / 4.17 minutes = tweet_result6


#%%##데이터 저장
model_list=['author_id','date','favorites','hashtags','id','replies','retweets','text','username']


tweets=[]
for tweet in tweet_result1:
    tweets.append([tweet.author_id, tweet.date, tweet.favorites,tweet.hashtags, tweet.id, tweet.replies,
                   tweet.retweets, tweet.text, tweet.username])
tweet_df = pd.DataFrame(tweets,columns=model_list)

tweets=[]
for tweet in tweet_result2:
    tweets.append([tweet.author_id, tweet.date, tweet.favorites,tweet.hashtags, tweet.id, tweet.replies,
                   tweet.retweets, tweet.text, tweet.username])
tweet_ex = pd.DataFrame(tweets,columns=model_list)
tweet_df=tweet_df.append(tweet_ex)
    
tweets=[]
for tweet in tweet_result3:
    tweets.append([tweet.author_id, tweet.date, tweet.favorites,tweet.hashtags, tweet.id, tweet.replies,
                   tweet.retweets, tweet.text, tweet.username])
tweet_ex = pd.DataFrame(tweets,columns=model_list)
tweet_df=tweet_df.append(tweet_ex)
    
tweets=[]
for tweet in tweet_result4:
    tweets.append([tweet.author_id, tweet.date, tweet.favorites,tweet.hashtags, tweet.id, tweet.replies,
                   tweet.retweets, tweet.text, tweet.username])
tweet_ex = pd.DataFrame(tweets,columns=model_list)
tweet_df=tweet_df.append(tweet_ex)
    
tweets=[]
for tweet in tweet_result5:
    tweets.append([tweet.author_id, tweet.date, tweet.favorites,tweet.hashtags, tweet.id, tweet.replies,
                   tweet.retweets, tweet.text, tweet.username])
tweet_ex = pd.DataFrame(tweets,columns=model_list)
tweet_df=tweet_df.append(tweet_ex)
    
tweets=[]
for tweet in tweet_result6:
    tweets.append([tweet.author_id, tweet.date, tweet.favorites,tweet.hashtags, tweet.id, tweet.replies,
                   tweet.retweets, tweet.text, tweet.username])
tweet_ex = pd.DataFrame(tweets,columns=model_list)
tweet_df=tweet_df.append(tweet_ex)


DataFrame.to_csv(tweet_df,'twitter_data.csv',index=False, encoding='utf-8-sig')
#tweet_df = pd.read_csv('twitter_data.csv',encoding='utf-8')


#%%팔로워 크롤링 및 저장
retweet_sum=pd.DataFrame(tweet_df.groupby(['author_id','id', 'username']).sum()['retweets'])
retweet_sum=retweet_sum.sort_values(by='retweets', ascending=False).reset_index(drop=False)
DataFrame.to_csv(retweet_sum,'retweet_sum.csv',index=False)
retweet_sum = pd.read_csv('retweet_sum.csv',encoding='utf-8')


consumer_key = "MhtzQY6NjVUDtST98dFAxty22"
consumer_secret = "WJKh6fuC8js4FlvTKaUQQHOhHP6X817r4jXsrKUATVAqJxkTxl"
access_token = "2217878522-aBsMxfi8moJiedwVUOdGRr4svJmaEGASTuSuWbF"
access_token_secret = "RlumKYa9UBGbmQu4KGBocn8Evh0x7R9XD7vIKGfQQ11lq "

# 계정 승인
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
twitter_api = tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)

# user_id로 모든 팔로워 id 리턴 
bar = progressbaressbar.ProgressBar()
usernames = list(retweet_sum.iloc[0:135,2])
follower=[]
for i in bar(usernames):
    try:
        ids=[]
        for page in tweepy.Cursor(twitter_api.followers_ids, id=i).pages():
            ids.extend(page)
        follower.append(ids)
    except tweepy.TweepError:
        print("tweepy.TweepError=", tweepy.TweepError)
        follower.append(['error'])
    except:
        e = sys.exc_info()[0]
        print ("Error: %s" % e)
        follower.append(['error'])


#error 확인
error_names=[]
for i in range(len(usernames)):
    if follower[i]==['error']: error_names.append(usernames[i])
#error가 나타난 user_id='irene0427' : 17 index
retweet_sum.iloc[17,2]

error_id=[]
error_id.append(retweet_sum.iloc[17,1])
user_id = list(retweet_sum.iloc[0:135,1])
user_id_new=[x for x in user_id if x not in error_id]
#134개 id의 팔로워 리스트

error_author_id=[]
error_author_id.append(retweet_sum.iloc[17,0])
user_author_id = list(retweet_sum.iloc[0:135,0])
user_author_id=[x for x in user_author_id if x not in error_author_id]
#134개 id의 팔로워 author_id 리스트

    
#pickle파일로 저장
pickle.dump(user_author_id, open('E:/social_media/user_author_id_0_134.pickle', 'wb'))
pickle.dump(usernames, open('E:/social_media/usernames_0_134.pickle', 'wb'))
pickle.dump(user_id_new, open('E:/social_media/user_id_0_134.pickle', 'wb'))
pickle.dump(follower, open('E:/social_media/follower_0_134.pickle', 'wb'))
#pickle파일 불러오기
user_author_id=pickle.load(open('E:/social_media/user_author_id_0_134.pickle','rb'))
usernames=pickle.load(open('E:/social_media/usernames_0_134.pickle','rb'))
user_id_new=pickle.load(open('E:/social_media/user_id_0_134.pickle','rb'))
follower=pickle.load(open('E:/social_media/follower_0_134.pickle','rb'))


#134개의 id와 follower의 교집합 구하기
follower_new=[list(set(user_author_id).intersection(i)) for i in follower]
del follower_new[17]

# user_id 값은 노드번호로 보기 매우 힘들기 때문에 새로 노드번호로 지정(1~134)
user_id_table=pd.DataFrame({'user_id' : user_author_id})
user_id_table['num']=user_id_table.index+1
DataFrame.to_csv(user_id_table,'user_id_table.csv',index=False)



#%%
# 사용자 ID와 팔로워 리스트로 edgelist 생성
edge_from=[]
edge_to=[]
for i in range(len(follower_new)):
    if len(follower_new[i])==0: next
    else:
        for j in range(len(follower_new[i])):
            edge_from.append(follower_new[i][j])
            edge_to.append(user_author_id[i])
            
edgelist=pd.DataFrame({'edge_from' : edge_from, 'edge_to' : edge_to}) 
edgelist=pd.merge(edgelist, user_id_table, left_on='edge_from', right_on='user_id')   
edgelist=pd.merge(edgelist, user_id_table, left_on='edge_to', right_on='user_id')   
edgelist=edgelist.drop(['user_id_x','user_id_y'], axis=1)
DataFrame.to_csv(edgelist, 'edgelist.csv', index=False)



