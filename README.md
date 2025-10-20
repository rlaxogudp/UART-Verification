# SystemVerilog를 이용한 10000 Counter 및 UART 검증

**하만교육 2기 미니 프로젝트**
**Team**: 김태형, 황주빈

## 📌 1. 프로젝트 개요
본 프로젝트는 Verilog로 설계된 **UART 연동 10000 Counter** 모듈(DUT)과, 이를 검증하기 위한 **SystemVerilog 기반의 테스트벤치(Testbench)** 환경 구축을 목표로 합니다.

[cite_start]FPGA(Basys 3 보드)의 물리적 버튼 입력과 PC의 UART 명령어 입력을 모두 받아 카운터를 제어하며 [cite: 2646][cite_start], SystemVerilog를 이용해 `UART_TOP` 모듈의 `RX-FIFO-TX` Loopback 기능을 중점적으로 검증했습니다[cite: 2648, 2649].

---

## 🛠️ 2. DUT (Design Under Test) 아키텍처
[cite_start]전체 시스템은 `UART_TOP`, `CMD_CU`, 버튼 디바운서, `COUNTER`, `FND_CNTL` 모듈로 구성됩니다. [cite: 2657]

* [cite_start]**`UART_TOP`**: PC로부터 `RX` 데이터를 수신하고, `TX`로 데이터를 송신합니다. [cite: 2670, 2673, 2674]
* [cite_start]**`CMD_CU`**: `UART_TOP`에서 전달받은 `rx_data`를 해석하여 카운터 제어 신호(run, clear, mode)를 생성합니다. [cite: 2667, 2669, 2671]
* [cite_start]**`BD_D,L,R` (Button Debouncer)**: Basys 3 보드의 물리 버튼(`BTN_D,L,R`) 입력을 받아 디바운싱 처리를 합니다. [cite: 2659]
* [cite_start]**`COUNTER`**: `CMD_CU` 또는 버튼 입력으로부터 `enable`, `mode`, `clear` 신호를 받아 10000 카운터 동작을 수행합니다. [cite: 2663, 2665]
* [cite_start]**`FND_CNTL`**: `COUNTER`의 현재 값을 7-Segment 디스플레이에 표시합니다. [cite: 2666]

---

## 🔬 3. SystemVerilog 검증 환경 (Testbench)
`UART_TOP` 모듈의 무결성을 검증하기 위해 UVM(Universal Verification Methodology)과 유사한 클래스 기반의 SystemVerilog 테스트벤치 환경을 구축했습니다.

[cite_start] [cite: 2675-2683]

* [cite_start]**`Generator (GEN)`**: 검증에 사용할 8-bit 랜덤 데이터를 생성합니다. [cite: 2684]
* [cite_start]**`Driver (DRV)`**: `Generator`로부터 `gen2drv` 메일박스를 통해 트랜잭션(데이터)을 전달받습니다[cite: 2687, 2693]. [cite_start]이 데이터를 UART 프로토콜 타이밍에 맞게 DUT의 `rx` 핀으로 인가(drive)합니다[cite: 2703].
* [cite_start]**`Monitor (MON)`**: DUT의 `tx` 핀을 모니터링하여 UART 송신 데이터를 캡처합니다[cite: 2712].
* **`Scoreboard (SCB)`**:
    * [cite_start]`DRV`로부터 원본 데이터(Expected)를 `drv2mon` 메일박스를 통해 전달받습니다. [cite: 2704]
    * [cite_start]`MON`으로부터 `tx` 핀에서 캡처된 실제 결과 데이터(Actual)를 `mon2scb` 메일박스를 통해 전달받습니다. [cite: 2682]
    * [cite_start]두 데이터를 비교하여 `UART_TOP` 모듈의 `RX -> FIFO -> TX` Loopback 동작이 정상적인지 판별합니다. [cite: 2723]
* [cite_start]**`Interface`**: DUT와 테스트벤치 컴포넌트 간의 신호 연결을 담당합니다. [cite: 2680]

---

## 📊 4. 검증 결과
* [cite_start]**RX 검증**: Driver가 보낸 `0x44` 데이터를 DUT의 `UART_RX` 모듈이 성공적으로 수신함을 확인했습니다. [cite: 2758, 2807]
* [cite_start]**TX 검증**: `UART_TX` 모듈이 `0x44` 데이터를 UART 프로토콜에 맞게 `tx` 핀으로 정상 송신함을 확인했습니다. [cite: 2958, 2984-3028]
* [cite_start]**FIFO 검증**: `RX_FIFO`와 `TX_FIFO` 간의 데이터 (`0x44`) 전달이 정상적으로 이루어짐을 시뮬레이션으로 확인했습니다. [cite: 2870, 2881-2919]
* [cite_start]**최종 리포트**: 256개의 랜덤 트랜잭션을 실행하여 **100.00%의 Pass Rate**를 달성했습니다. [cite: 3048, 3050, 3054]
* [cite_start]**DUT 시뮬레이션**: 별도 시뮬레이션을 통해 물리 버튼 및 UART 명령어(`r`: start/stop, `m`: mode, `r`: reset)로 카운터가 정상 동작함을 확인했습니다. [cite: 3187-3190, 3231-3233]

---

## 🐛 5. 트러블슈팅 (Trouble Shooting)
검증 환경 구축 과정에서 발생한 주요 문제 및 해결 과정입니다.

### 5-1. Mailbox 데이터 동기화 오류
* [cite_start]**문제**: `Monitor`가 `Scoreboard`와의 비교를 위해 `drv2mon` 메일박스에서 원본 데이터를 `get`하려 할 때, 아직 `Driver`가 데이터를 `put`하지 않아 빈 트랜잭션을 참조하는 오류가 발생했습니다. [cite: 3239, 3263]
* [cite_start]**해결**: `Driver`가 `drv2mon_mbox.put(trans)`를 먼저 실행하고, `Monitor`가 `drv2mon_mbox.get(trans)` 하도록 이벤트 순서를 명확히 제어하여 동기화 문제를 해결했습니다. [cite: 3267-3272, 3301, 3365]

### 5-2. RX Data Catch 타이밍 오류
* [cite_start]**문제**: `Driver`가 DUT의 `rx_data` 레지스터 값을 샘플링할 때, DUT 내부의 `cmd_start` 신호가 활성화되기 전의 불안정한 값을 읽어와 `FAIL`이 발생했습니다. [cite: 3322, 3332-3336]
* [cite_start]**해결**: `Driver` 태스크 내부에 `@(negedge uart_fifo_if.cmd_start)` 구문을 추가하여 [cite: 3347][cite_start], `cmd_start` 신호가 발생(데이터가 유효해짐)한 직후에 `rx_data`를 샘플링하도록 타이밍을 수정했습니다. [cite: 3348]

### 5-3. 검증 로직 분리 (Driver -> Monitor)
* [cite_start]**문제**: 초기 설계에서 `Driver`가 DUT의 `RX` 데이터 비교(검증)까지 담당했습니다. [cite: 3353-3362]
* **해결**: 테스트벤치 역할 구분에 따라 로직을 수정했습니다. [cite_start]`Driver`는 데이터 인가(Drive)만 담당하고 [cite: 3368][cite_start], `Monitor`가 DUT의 응답을 확인하고 `Scoreboard`가 비교하도록 검증 책임을 올바르게 재분배했습니다. [cite: 3371, 3378]
