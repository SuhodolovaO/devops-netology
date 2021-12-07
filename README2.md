### Задача 3

Перевод метров в футы
```
package main

import "fmt"

func main() {
	fmt.Print("Enter a number: ")
	var meters float64
	fmt.Scanf("%f", &meters)

	feet := GetFeetFromMeters(meters)

	fmt.Printf("%.4f meters is %.4f feet\n", meters, feet)
}

func GetFeetFromMeters(meters float64) float64 {
	return meters / 0.3048
}
```

Поиск наименьшего элемента
```
package main

import "fmt"

func main() {
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
    result, err := getSmallestElement(x)

    if err != nil {
        fmt.Println(err)
    } else {
        fmt.Println(result)
    }
}

func getSmallestElement(list []int) (int, error) {
    if len(list) == 0 {
        return 0, fmt.Errorf("Array is empty!")
    }

    var smallest = list[0]
    for _, value := range list {
        if value < smallest {
            smallest = value
        }
    }
    return smallest, nil
}
```

Вывод чисел от 1 до 100, которые делятся на 3
```
package main

import "fmt"

func main() {
	maxValues := 100
	numbers := GetNumbersDividedByThree(maxValues)
	fmt.Println(numbers)
}

func GetNumbersDividedByThree(maxValues int) []int  {
	numbers := []int{}
	for i :=0; i <= maxValues; i++ {
		if i%3 == 0 {
			numbers = append(numbers, i)
		}
	}
	return numbers
}
```

### Задача 4

Тест перевода метров в футы
```
package main
import "testing"

func testMain(t *testing.T) {
	feet := GetFeetFromMeters(10)
	if feet != 32.808399 {
		t.Error("Expected 32.808399, got ", feet)
	}
}
```

Тест поиска наименьшего элемента
```
package main
import "testing"

func testMain(t *testing.T) {
	x := []int{1,2,3}
	smallest, err := getSmallestElement(x)
	if smallest != 1 {
		t.Error("Expected 1, got ", smallest)
	}
}
```

Тест вывода чисел, кратных 3
```
package main
import "testing"

func testMain(t *testing.T) {
	numbers := GetNumbersDividedByThree(10)
	if (len(numbers) != 4 || numbers[0] != 0 || numbers[1] != 3 || numbers[2] != 6 || numbers[3] != 9) {
		t.Error("Unexpected result ", numbers)
	}
}
```