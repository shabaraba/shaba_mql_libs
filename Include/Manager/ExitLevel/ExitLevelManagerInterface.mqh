interface ExitLevelManager {
    void wonThen();
    void loseThen();
    double getTp(double price, ENUM_POSITION_TYPE type);
    double getSl(double price, ENUM_POSITION_TYPE type);
};
