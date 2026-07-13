# my_list = [num for num in range(20, 10, -1)]

# # result = my_list.sort()
# # result = sorted(my_list)

# print(result)

raw_data = ["100", "200", "300"]

# 1. 먼저 정수로 변신시키는 map 상자를 만들고
transformed = map(int, raw_data)

print(transformed)

def discoounted_price(price, discount_rate):
    discount_amount = price * (discount_rate / 100)
    discounted_price = price - discount_amount

    return discoounted_price

discounted_price = lambda price, discount_rate : price * (discount_rate / 100)

# sum_result = 