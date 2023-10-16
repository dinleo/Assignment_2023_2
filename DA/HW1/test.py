import MeCab

m = MeCab.Tagger()
t = m.parse('안녕하세요 저는 김김입니다')
print(t)