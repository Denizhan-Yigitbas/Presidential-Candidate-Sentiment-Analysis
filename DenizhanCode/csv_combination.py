import pandas as pd

def reorganizeCSV(csv_file, twitterHandle):
    df = pd.read_csv(csv_file)
    df = df.rename(columns={'favorite_count': 'favoriteCount',
                                  'id_str': 'id',
                                  'retweet_count': 'retweetCount',
                                  'created_at': 'createdDate',
                                  'is_retweet': 'tweetBinary'})
    df = df.drop(columns=['in_reply_to_screen_name', 'source'])
    df.insert(0, "candidate", twitterHandle)
    df = df[['candidate', 'id', 'text', 'createdDate', 'favoriteCount', 'retweetCount', 'tweetBinary']]
    df['tweetBinary'] = df['tweetBinary'].map({False: 1, True: 0})
    df = df.set_index('candidate')
    return df


ApiPulled = pd.read_csv('2016ApiPull.csv').set_index('candidate')

Trump = reorganizeCSV('realdonaldtrump.csv', 'realDonaldTrump')
Bush = reorganizeCSV('jebbush.csv', 'JebBush')
Cruz = reorganizeCSV('tedcruz.csv', 'TedCruz')
Huckabee = reorganizeCSV('govmikehuckabee.csv', 'GovMikeHuckabee')
Kasich = reorganizeCSV('johnkasich.csv', 'JohnKasich')
Paul = reorganizeCSV('randpaul.csv', 'RandPaul')
Rubio = reorganizeCSV('marcorubio.csv', 'MarcoRubio')
Walker = reorganizeCSV('scottwalker.csv', 'ScottWalker')

FinalDataFrame = ApiPulled.append([Trump, Bush, Cruz, Huckabee, Kasich, Paul, Rubio, Walker])

FinalDataFrame.to_csv('finalDataSet_2016.csv')