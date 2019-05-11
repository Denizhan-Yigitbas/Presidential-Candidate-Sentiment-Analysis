import pandas as pd
import matplotlib.pyplot as plt
import statistics


df = pd.read_csv('customTwitterUsersCombinedCleaned.csv')
df1 = df.set_index('candidate')

def polarityVSpopularity(DataFrame, Candidate):
    # using polarity instead of sentiment for this csv
    candData = DataFrame.loc[Candidate]
    Candidate_fav = candData[["polarity", "favoriteCount"]]
    Candidate_fav = Candidate_fav.sort_values(by=['polarity'], ascending=False)
    Candidate_ret = candData[["polarity", "retweetCount"]]
    Candidate_ret = Candidate_ret.sort_values(by=['polarity'], ascending=False)
    polarity = list(candData['polarity'])
    roundedPolarity = []
    for num in polarity:
        rounded = round(num, 1)
        roundedPolarity.append(rounded)
    favoriteCount = list(candData['favoriteCount'])
    retweetCount = list(candData['retweetCount'])
    combined_fav = list(zip(roundedPolarity, favoriteCount))
    combined_ret = list(zip(roundedPolarity, retweetCount))
    
    dic_fav = {}
    for group in combined_fav:
        if group[0] not in dic_fav:
            dic_fav[group[0]] = [group[1]]
        else:
            dic_fav[group[0]].append(group[1])
            
    for key, value in dic_fav.items():
        # do something with value
        dic_fav[key] = round(statistics.mean(value),0)

    plt.figure(figsize=(12, 5))
    plt.subplot(1, 2, 1)
    plt.xlabel("Polarity")
    plt.ylabel("Number of Favorites")
    plt.title("%s - Polarity vs favoriteCount"%str(Candidate))
    plt.bar(list(dic_fav.keys()), list(dic_fav.values()), width=0.1)
    
    dic_ret = {}
    for group in combined_ret:
        if group[0] not in dic_ret:
            dic_ret[group[0]] = [group[1]]
        else:
            dic_ret[group[0]].append(group[1])
    
    for key, value in dic_ret.items():
        # do something with value
        dic_ret[key] = round(statistics.mean(value), 0)
    

    plt.subplot(1, 2, 2)
    plt.xlabel("Polarity")
    plt.ylabel("Number of Retweets")
    plt.title("%s - Polarity vs retweetCount"%str(Candidate))
    plt.bar(list(dic_ret.keys()), list(dic_ret.values()), width=0.1)
    plt.show()

polarityVSpopularity(df1, 'JoeBiden')
polarityVSpopularity(df1, 'CoryBooker')
polarityVSpopularity(df1, 'JulianCastro')
polarityVSpopularity(df1, 'TulsiGabbard')
polarityVSpopularity(df1, 'SenGillibrand')
polarityVSpopularity(df1, 'KamalaHarris')
polarityVSpopularity(df1, 'amyklobuchar')
polarityVSpopularity(df1, 'BetoORourke')
polarityVSpopularity(df1, 'BernieSanders')
polarityVSpopularity(df1, 'ewarren')
polarityVSpopularity(df1, 'AndrewYang')

