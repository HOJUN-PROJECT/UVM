UVM 학습 및 실습 내용 정리

본 프로젝트는 하만(Harman) 교육 과정에서 학습한 UVM(Unified Verification Methodology)을 기반으로,
기본 구조 이해부터 심화 개념 적용까지 단계적으로 실습한 내용을 정리한 것입니다.
검증 대상 DUT는 Adder이며, UVM 환경 구성 및 시나리오 확장을 중심으로 학습하였습니다.

1. 기본 UVM 구조 실습 (adder)

UVM의 표준 구조와 각 컴포넌트의 역할을 이해하는 것을 목표로 한 기본 실습
UVM Environment 구성
- sequence
- sequencer
- driver
- monitor
- agent
- scoreboard

주요 학습 내용
- Sequence를 통한 트랜잭션 생성
- Sequencer–Driver 간 핸드셰이크 구조 이해
- Monitor를 이용한 DUT 출력 관찰
- Scoreboard를 통한 결과 비교 및 검증
- UVM Phase 개념(build, connect, run 등) 이해
→ UVM의 전체적인 흐름과 컴포넌트 간 역할 분담을 파악하는 데 중점을 둠

2. 심층 UVM 실습 (adder_final)
기본 UVM 구조를 확장하여 가독성, 재사용성, 유연성을 향상시키는 방향으로 개선한 심화 실습
- Virtual Sequence 적용
- 여러 Sequence를 상위 레벨에서 제어
- Test 레벨에서 시나리오 구성이 간결해짐
- 내부 Sequencer 간 연결을 보다 직관적으로 관리 가능
- do 매크로 활용
- 반복적인 Sequence 실행 코드를 간소화
- 코드 라인 수 감소로 유지보수성 향상
- 다양한 테스트 시나리오에 대한 확장 용이

개선 효과
- 테스트 시나리오 작성 효율 증가
- 환경 재사용성 및 확장성 강화
- 실제 프로젝트에 가까운 UVM Testbench 구조 경험

3. 참고 링크
EDAPLAYGROUND 시뮬레이션 코드
👉 https://www.edaplayground.com/x/DPSeI
