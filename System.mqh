typedef void (*PROCESS_FUNC)(void);

class WrappedSystem {
public:
    static void OnCandle(PROCESS_FUNC func);
    static void OnCandle(string symbol, ENUM_TIMEFRAMES period, PROCESS_FUNC func);
};

void WrappedSystem::OnCandle(PROCESS_FUNC func) {
    WrappedSystem::OnCandle(_Symbol, PERIOD_CURRENT, func);
};

void WrappedSystem::OnCandle(string symbol, ENUM_TIMEFRAMES period, PROCESS_FUNC func) {
    datetime currentDatetime = iTime(symbol, period, 1);
    static datetime lastDatetime = currentDatetime;

    if (lastDatetime == currentDatetime) {
        return;
    }

    lastDatetime = currentDatetime;
    func();
};
