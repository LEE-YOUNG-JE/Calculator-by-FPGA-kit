# Calculator-by-FPGA-kit

# 과제
FPGA Kit에서 7-segment 모듈과 Keypad 모듈을 이용하여 사칙연산 계산기를 만든다.

# 설계 목표
 이번 설계의 목표는 6자리 숫자를 사칙 연산할 수 있는 계산기 설계하는 것이다. 입력된 숫자는 7 segment 모듈에 표시하고, 숫자와 연산기호를 번갈아 가며 입력 후 “=“를 입력하여 연산을 마무리한다. 단, 나눗셈은 정수 자리의 몫만 출력하고, 연산자 우선순위 무시하는 계산기를 설계하는 것이다.

# 요구사항에 대한 분석 및 해결 방안
1) 숫자와 연산기호를 번갈아 가며 입력 후 “=“를 입력하여 연산 마무리
 Segment에 출력되는 값은 set_no1, set_no2, set_no3, set_no4, set_no5, set_no6으로 구성된다. 예를 들어 첫 번째 수를 입력하면 값은 set_no1에 들어가게 되고 두 번째 수를 입력하면 set_no2에 출력되게끔 설정한다. 그리고 cal_result란 값과 num_temp란 값을 만들어서 num_temp는 일시적으로 입력받은 수를 입력하여 cal_result에 연산이 계속되도록 만든다. 따라서 =을 입력하면 cal_result를 num_temp와 set_no1, set_no2, set_no3, set_no4, set_no5, set_no6을 이용해 Segment에 출력하게 한다. 

2) 나눗셈은 정수 자리의 몫만 출력 
 나눗셈은 몫과 나머지의 개념이 있지만, 이번 설계의 목표는 정수 자리의 몫만 출력하는 것이므로, 소수점을 나타 낼 필요도 없고, 나머지를 나타 낼 필요도 없다. 예를 들면 3나누기 2는 1.5가 나와야 하지만 이번 설계로 만든 계산기는 3/2=1이 나와야 한다. 코드는 나누기 연산기능에 /기능을 사용한다.

3) 연산자 우선순위 무시
 연산자 우선순위 무시는 3+3*4를 했을 때, 15가 아닌, 24가 나와야한다. 이는 cal_result가 계속 최신 연산이 되도록 되므로 자연스레 우선순위가 무시되고 순서대로 계산된다.

4) 0으로 나누었을 때 Error 출력
 연산자를 진행 할 때, stack이라는 변수를 1,2,3,4,5 순서대로 +,-,*,/%라고 정하였다. 그래서 이전에 입력한 값이 /일 때(stack이 3일 때) 그 다음오는 값이 0이면 0으로 나누는 값이 되어버리므로 에러가 출력되게 한다. 하지만 시간부족으로 인해 코드를 완성하지는 못하였다.

5) Overflow(>999999), Underflow(<0)시 Error 출력
 주어진 코드를 보면 입력한 코드의 범위를 벗어나면 cal_result > 999999이 되는데, 이 상태를 error상태로 만든다. 


# 상세한 설계 내용
- set_no1~6은 현재입력값이 저장되는 곳이고 이것을 이용하여 연산에 활용된다.

- stack은 1~5까지 값이 있어서 1=덧셈, 2=뺄셈, 3=곱셈, 4=나눗셈, 5=나머지 연산자를 기억하는 변수로써 이전 연산자를 불러와서 계산할 때 쓰이는 변수이다.

- num_temp는 중간계산 과정중에 값을 저장해야 하는 곳이 필요한데 그 값을 저장하는 변수이다.

- cal_result는 마지막에 num_temp값을 받아와서 최종적으로 출력하기위해 필요한 변수이다.

- on은 enter를 눌렀을 때만 실행되게끔 하는 변수로써 enter를 누르게 되면 최종 연산값인 cal_result의 값을 비교한다. 여기서 cal_result의 값을 비교하는 이유는 cal_result는 현재 십진수의 값을 기억하고 있지만 우리가 원하고자 하는 출력은 자릿수 별로 분할하여 segment에 나타내는 것이다. 따라서 범위를 나누어서 각각의 숫자를 분리하는 과정이 필요하다.

- ‘h0001부터 ’h8000까지 있는데 전체적인 코드를 분석하면 숫자부분은 계산기의 현재 state를 조건으로 나누어서 예를 들어 현재 state가 sw_2인데 1이 입력되면 세 자리 수가 되어야 하므로 sw_3으로 상태를 변환시켜준다. 그리고나서 set_no3에 1을 넣어주는 방식이다. 방금 입력한 연산자도 기억해야 하므로 방금 입력한 연산자의 해당 숫자를 stack에 저장하도록 한다.

- .연산자부분은 이전에 계산된 적이 있는지와 없는지로 나누고 만약 계산된 적이 없다면(sum=0) 처음 입력이므로 바로 num_temp에 값을 넣는다. 반대로 계산된 적이 있다면(sum=1) 계산된 이전값과 현재값을 이전 연산자로 계산하여 num_temp에 넣는다. 그리고 set_no1~6은 자릿수만 알고 직접 한번에 계산이 불가능하므로 자리수별로 나누어서 10의 거듭제곱을 이용하여 연산을 실행한다.

- enter같은 경우도 사실상 다른 연산자랑 비슷한 느낌이기 때문에 마지막에 입력된 값의 자릿수를 조건으로 나누어서 연산하고 num_temp에 저장한 후 이 값이 출력되어야하므로 cal_result로 값을 복사한다. 그리고 한번 연산 후에 계산기가 끝나는 것이 아니므로 모든 변수들의 값들을 초기화 해주기 위해서 state를 sw_idle로 변환하도록 한다.