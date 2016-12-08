import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('growth.txt', ';' , names=['Max Fitness', 'Average Fitness', 'Lowest fitness'])

df = df[:-1]
i = 0
for i in range(0,26):
    df = df.drop(i)
df=df.astype(float)

print(df)

plt.figure(); df.plot(legend=True)
plt.savefig('foo.png')