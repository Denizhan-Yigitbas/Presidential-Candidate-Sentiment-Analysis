from TwitterUser import *
import csv

consumer_key = 'fsIJrsm2M2H7EqhBTAY2L2FE6'
consumer_secret = 'pEImfs7hw6OXPA3coF4ySPq5tkzAMOXfjfYVRpPUQlRUbDHVos'
access_key = '723047418-ssrsLkCiMNg1zGrJCVTL6HhPeUSllMf8KrQ6W2TA'
access_secret = 'Zfr7jCXX5iM7N0VlRqtvmJ46RqBukmt2Q4QUKnxsn7g2h'

# Connor = TwitterUser('CL_Rothschild', consumer_key, consumer_secret, access_key, access_secret)

Joe_Biden = TwitterUser('JoeBiden', consumer_key, consumer_secret, access_key, access_secret)
Cory_Booker = TwitterUser('CoryBooker', consumer_key, consumer_secret, access_key, access_secret)
Pete_Buttigieg = TwitterUser('PeteButtigieg', consumer_key, consumer_secret, access_key, access_secret)
Julian_Castro = TwitterUser('JulianCastro', consumer_key, consumer_secret, access_key, access_secret)
Tulsi_Gabbard = TwitterUser('TulsiGabbard', consumer_key, consumer_secret, access_key, access_secret)
Kirsten_Gillibrand = TwitterUser('SenGillibrand', consumer_key, consumer_secret, access_key, access_secret)
Kamala_Harris = TwitterUser('KamalaHarris', consumer_key, consumer_secret, access_key, access_secret)
Amy_Klobuchar = TwitterUser('amyklobuchar', consumer_key, consumer_secret, access_key, access_secret)
Beto_ORourke = TwitterUser('BetoORourke', consumer_key, consumer_secret, access_key, access_secret)
Bernie_Sanders = TwitterUser('BernieSanders', consumer_key, consumer_secret, access_key, access_secret)
Elizabeth_Warren = TwitterUser('ewarren', consumer_key, consumer_secret, access_key, access_secret)
Andrew_Yang = TwitterUser('AndrewYang', consumer_key, consumer_secret, access_key, access_secret)

allCandidates = [Joe_Biden, Cory_Booker, Pete_Buttigieg, Julian_Castro, Tulsi_Gabbard,
                 Kirsten_Gillibrand, Kamala_Harris, Amy_Klobuchar, Beto_ORourke, Bernie_Sanders,
                 Elizabeth_Warren, Andrew_Yang]

# combinedCleanedCSV(allCandidates)
# combinedUncleanedCSV(allCandidates)
# sample(allCandidates)
