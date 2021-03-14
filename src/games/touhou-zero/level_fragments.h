#define make_caravan(start_time, x, tile, type, hp, bonus)      \
    case start_time:                                            \
        push_npc(x, -32, 0, 2, tile, type, hp, bonus);          \
        push_npc(x + 32, -32, 0, 2, tile, type, hp, bonus);     \
        break;                                                  \
    case start_time + 5:                                        \
        push_npc(x, -32, 0, 2, tile, type + 1, hp, bonus);      \
        push_npc(x + 32, -32, 0, 2, tile, type + 1, hp, bonus); \
        break;                                                  \
    case start_time + 10:                                       \
        push_npc(x, -32, 0, 2, tile, type + 2, hp, bonus);      \
        push_npc(x + 32, -32, 0, 2, tile, type + 2, hp, bonus); \
        break;                                                  \
    case start_time + 15:                                       \
        npc_by_type_set_speed(type, (x > 160) ? -4 : 4, 0);     \
        break;                                                  \
    case start_time + 20:                                       \
        npc_by_type_set_speed(type + 1, (x > 160) ? -4 : 4, 0); \
        break;                                                  \
    case start_time + 25:                                       \
        npc_type_shoot(type, 3, 3);                             \
        npc_type_shoot(type + 1, 4, 3);                         \
        npc_type_shoot(type + 2, 5, 3);                         \
        npc_by_type_set_speed(type + 2, (x > 160) ? -4 : 4, 0); \
        break;                                                  \
    case start_time + 27:                                       \
        npc_type_shoot(type, 2, 3);                             \
        npc_type_shoot(type + 1, 1, 3);                         \
        npc_type_shoot(type + 2, 0, 3);                         \
        break;                                                  \
    case start_time + 29:                                       \
        npc_type_shoot(type, 1, 3);                             \
        npc_type_shoot(type + 1, 0, 3);                         \
        npc_type_shoot(type + 2, -1, 3);                        \
        break;                                                  \
    case start_time + 35:                                       \
        npc_by_type_set_speed(type, 1, 3);                      \
        npc_by_type_set_speed(type + 1, 0, 3);                  \
        npc_by_type_set_speed(type + 2, -2, 3);                 \
        break;

#define make_double_caravan(start_time, tile, type, hp, bonus) \
    case start_time:                                           \
        push_npc(32, -32, 0, 2, tile, type, hp, bonus);        \
        push_npc(270, -32, 0, 2, tile, type + 10, hp, bonus);  \
        break;                                                 \
    case start_time + 4:                                       \
        push_npc(32, -32, 0, 2, tile, type + 1, hp, bonus);    \
        push_npc(270, -32, 0, 2, tile, type + 11, hp, bonus);  \
        break;                                                 \
    case start_time + 8:                                       \
        push_npc(32, -32, 0, 2, tile, type + 2, hp, bonus);    \
        push_npc(270, -32, 0, 2, tile, type + 12, hp, bonus);  \
        break;                                                 \
    case start_time + 9:                                       \
        npc_by_type_set_speed(type, 2, 0);                     \
        npc_by_type_set_speed(type + 10, -2, 0);               \
        break;                                                 \
    case start_time + 14:                                      \
        npc_by_type_set_speed(type + 1, 2, 0);                 \
        npc_by_type_set_speed(type + 11, -2, 0);               \
        break;                                                 \
    case start_time + 19:                                      \
        npc_by_type_set_speed(type + 2, 2, 0);                 \
        npc_by_type_set_speed(type + 12, -2, 0);               \
        break;                                                 \
    case start_time + 20:                                      \
        npc_aimed_shoot(type);                            \
        npc_aimed_shoot(type + 1);                        \
        npc_aimed_shoot(type + 2);                        \
        npc_aimed_shoot(type + 10);                      \
        npc_aimed_shoot(type + 11);                      \
        npc_aimed_shoot(type + 12);                      \
        break;                                                 \
    case start_time + 21:                                      \
        npc_by_type_set_speed(type + 10, 0, 2);                \
        npc_by_type_set_speed(type + 11, 0, 2);                \
        npc_by_type_set_speed(type + 12, 0, 2);                \
        npc_by_type_set_speed(type, 0, 2);                     \
        npc_by_type_set_speed(type + 1, 0, 2);                 \
        npc_by_type_set_speed(type + 2, 0, 2);                 \
        break;

#define make_boom_fairy(start_time, x, hp, bonus)       \
    case start_time:                                    \
        push_npc(x, -32, 0, 5, FIARY3, 100, hp, bonus); \
        break;                                          \
    case start_time + 3:                                \
        npc_by_type_set_speed(100, 0, 0);               \
        break;                                          \
    case start_time + 5:                                \
        npc_type_star(100);                             \
        break;                                          \
    case start_time + 7:                                \
        npc_type_star(100);                             \
        break;                                          \
    case start_time + 11:                               \
        npc_by_type_set_speed(100, 2, 2);               \
        break;

#define left_flyers(start_time, y, tile, hp, bonus)   \
    case start_time:                                  \
    case start_time + 3:                              \
    case start_time + 6:                              \
        push_npc(320, y, -3, 0, tile, 30, hp, bonus); \
        break;

#define right_flyers(start_time, y, tile, hp, bonus) \
    case start_time:                                 \
    case start_time + 3:                             \
    case start_time + 6:                             \
        push_npc(-20, y, 3, 0, tile, 30, hp, bonus); \
        break;

#define just_star(start_time, x, y) \
    case start_time:                \
        push_star(x, y);            \
        break;

#define boss_shoot1(start_time, x, y) \
    case start_time:                  \
        push_star(x, y);              \
        break;                        \
    case start_time + 1:              \
        push_bullet(x, y, -2, 3);     \
        break;                        \
    case start_time + 2:              \
        push_bullet(x, y, -1, 4);     \
        break;                        \
    case start_time + 3:              \
        push_bullet(x, y, 0, 5);      \
        break;                        \
    case start_time + 4:              \
        push_bullet(x, y, -2, 3);     \
        push_bullet(x, y, 1, 4);      \
        break;                        \
    case start_time + 5:              \
        push_bullet(x, y, -1, 4);     \
        push_bullet(x, y, 2, 3);      \
        break;                        \
    case start_time + 6:              \
        push_bullet(x, y, 0, 5);      \
        push_bullet(x, y, 1, 4);      \
        break;                        \
    case start_time + 7:              \
        push_bullet(x, y, 0, 5);      \
        push_bullet(x, y, 0, 5);      \
        break;                        \
    case start_time + 8:              \
        push_bullet(x, y, 1, 4);      \
        push_bullet(x, y, -1, 4);     \
        break;                        \
    case start_time + 9:              \
        push_bullet(x, y, 2, 3);      \
        push_bullet(x, y, -2, 3);     \
        break;

#define make_corridor(start_time, tile, type, hp, bonus)     \
    case start_time:                                         \
    case start_time + 3:                                     \
    case start_time + 6:                                     \
    case start_time + 9:                                     \
        push_npc(10, -32, 0, 3, tile, type, hp, bonus);      \
        push_npc(290, -32, 0, 3, tile, type + 1, hp, bonus); \
        break;                                               \
    case start_time + 16:                                    \
        npc_by_type_set_speed(type, 0, 0);                   \
        npc_by_type_set_speed(type + 1, 0, 0);               \
        break;                                               \
    case start_time + 18:                                    \
        npc_aimed_shoot(type);                               \
        npc_aimed_shoot(type + 1);                            \
        break;                                               \
    case start_time + 19:                                    \
        npc_by_type_set_speed(type, 0, 3);                   \
        npc_by_type_set_speed(type + 1, 0, 3);               \
        break;

#define enemy_wave(start_time, tile, type, hp)           \
    case start_time:                                     \
        push_npc(144, -32, 2, 2, tile, type, hp, 0);     \
        push_npc(176, -32, 2, 2, tile, type, hp, 0);     \
        break;                                           \
    case start_time + 5:                                 \
        push_npc(144, -32, 2, 2, tile, type + 1, hp, 0); \
        push_npc(176, -32, 2, 2, tile, type + 1, hp, 0); \
        npc_by_type_set_speed(type, 0, 2);               \
        break;                                           \
    case start_time + 10:                                \
        push_npc(144, -32, 2, 2, tile, type + 2, hp, 0); \
        push_npc(176, -32, 2, 2, tile, type + 2, hp, 0); \
        npc_by_type_set_speed(type, -2, 2);              \
        npc_by_type_set_speed(type + 1, 0, 2);           \
        break;                                           \
    case start_time + 15:                                \
        push_npc(144, -32, 2, 2, tile, type, hp, 0);     \
        push_npc(176, -32, 2, 2, tile, type, hp, 0);     \
        npc_type_shoot(type, 3, 0);                      \
        npc_type_shoot(type, -3, 0);                     \
        npc_type_shoot(type + 1, 3, 0);                  \
        npc_type_shoot(type + 1, -3, 0);                 \
        npc_type_shoot(type + 2, 3, 0);                  \
        npc_type_shoot(type + 2, -3, 0);                 \
        npc_by_type_set_speed(type, 0, 2);               \
        npc_by_type_set_speed(type + 1, -2, 2);          \
        npc_by_type_set_speed(type + 2, 0, 2);           \
        break;                                           \
    case start_time + 20:                                \
        npc_by_type_set_speed(type, 2, 2);               \
        npc_by_type_set_speed(type + 1, 0, 2);           \
        npc_by_type_set_speed(type + 2, -2, 2);          \
        npc_type_shoot(type, 3, 3);                      \
        npc_type_shoot(type, -3, 3);                     \
        npc_type_shoot(type + 1, 3, 0);                  \
        npc_type_shoot(type + 1, -3, 0);                 \
        npc_type_shoot(type + 2, 3, -3);                 \
        npc_type_shoot(type + 2, -3, -3);                \
        break;                                           \
    case start_time + 25:                                \
        npc_by_type_set_speed(type, 0, 2);               \
        npc_by_type_set_speed(type + 1, 2, 2);           \
        npc_by_type_set_speed(type + 2, 0, 2);           \
        npc_type_shoot(type, 3, 3);                      \
        npc_type_shoot(type, -3, 3);                     \
        npc_type_shoot(type + 1, 3, 0);                  \
        npc_type_shoot(type + 1, -3, 0);                 \
        npc_type_shoot(type + 2, 3, -3);                 \
        npc_type_shoot(type + 2, -3, -3);                \
        break;                                           \
    case start_time + 30:                                \
        npc_by_type_set_speed(type, -2, 2);              \
        npc_by_type_set_speed(type + 1, 0, 2);           \
        npc_by_type_set_speed(type + 2, 2, 2);           \
        npc_type_shoot(type, 3, -3);                     \
        npc_type_shoot(type, -3, -3);                    \
        npc_type_shoot(type + 1, 3, -3);                 \
        npc_type_shoot(type + 1, -3, -3);                \
        npc_type_shoot(type + 2, 3, -3);                 \
        npc_type_shoot(type + 2, -3, -3);                \
        break;                                           \
    case start_time + 35:                                \
        npc_by_type_set_speed(type, 0, 2);               \
        npc_by_type_set_speed(type + 1, 0, 2);           \
        npc_by_type_set_speed(type + 2, 0, 2);           \
        break;

#define make_enemies_pair(start_time, tile, type, hp) \
    case start_time: \
        push_npc(32, -32, 0, 2, tile, type, hp, 0); \
        push_npc(266, -32, 0, 2, tile, type, hp, 0); \
        break; \
    case start_time + 10: \
        npc_by_type_set_speed(type, 0, 0); \
        break; \
    case start_time + 11: \
        npc_type_star(type); \
        break; \
    case start_time + 15: \
        npc_by_type_set_speed(type, 0, 5); \
        break; 

#define make_shooting_star(start_time, tile, type, hp)        \
    case start_time:                                          \
        push_npc(97, 100, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 1:                                      \
        push_npc(109, 63, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 2:                                      \
        push_npc(141, 40, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 3:                                      \
        push_npc(180, 40, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 4:                                      \
        push_npc(212, 63, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 5:                                      \
        push_npc(224, 101, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 6:                                      \
        push_npc(212, 138, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 7:                                      \
        push_npc(180, 161, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 8:                                      \
        push_npc(141, 161, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 9:                                     \
        push_npc(109, 138, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 15:                                     \
    case start_time + 20:                                     \
    case start_time + 25:                                     \
        push_star(170, 110);                                  \
        break;                                                \
    case start_time + 30:                                     \
        npc_by_type_set_speed(type, 0, 5);                    \
        break;


#define make_star_xy(start_time, x, y, tile, type, hp)        \
    case start_time:                                          \
        push_npc(x - 52, y - 100, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 1:                                      \
        push_npc(x - 51, y - 37, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 2:                                      \
        push_npc(x - 19, y - 60, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 3:                                      \
        push_npc(x + 20, y - 60, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 4:                                      \
        push_npc(x + 52, y - 37, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 5:                                      \
        push_npc(x + 64, y, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 7:                                      \
        push_npc(x + 52, y + 38, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 8:                                      \
        push_npc(x + 20, y + 61, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 9:                                      \
        push_npc(x - 19, y + 61, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 10:                                     \
        push_npc(x - 51, y + 30, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 30:                                     \
        npc_by_type_set_speed(type, 0, 5);                    \
        break;
        
#define make_shooting_star_xy(start_time, x, y, tile, type, hp)        \
    case start_time:                                          \
        push_npc(x - 52, y - 100, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 1:                                      \
        push_npc(x - 51, y - 37, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 2:                                      \
        push_npc(x - 19, y - 60, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 3:                                      \
        push_npc(x + 20, y - 60, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 4:                                      \
        push_npc(x + 52, y - 37, 0, 0, tile, type, hp, BONUS_CARD);  \
        break;                                                \
    case start_time + 5:                                      \
        push_npc(x + 64, y, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 7:                                      \
        push_npc(x + 52, y + 38, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 8:                                      \
        push_npc(x + 20, y + 61, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 9:                                      \
        push_npc(x - 19, y + 61, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 10:                                     \
        push_npc(x - 51, y + 30, 0, 0, tile, type, hp, BONUS_CARD); \
        break;                                                \
    case start_time + 15:                                     \
    case start_time + 20:                                     \
    case start_time + 25:                                     \
        push_star(x + 10, y + 10);                                  \
        break;                                                \
    case start_time + 30:                                     \
        npc_by_type_set_speed(type, 0, 5);                    \
        break;

#define triangle(start_time, tile, hp, bonus) \
    case start_time: \
        push_npc(160, -10, 0, 2, tile, 10, hp, bonus); \
        break; \
    case start_time + 2: \
        push_npc(128, -10, 0, 2, tile, 11, hp, bonus); \
        push_npc(192, -10, 0, 2, tile, 11, hp, bonus); \
        break; \
    case start_time + 4: \
        push_npc(96, -10, 0, 2, tile, 12, hp, bonus); \
        push_npc(224, -10, 0, 2, tile, 12, hp, bonus); \
        break; \
    case start_time + 8: \
        push_npc(64, -10, 0, 2, tile, 13, hp, bonus); \
        push_npc(256, -10, 0, 2, tile, 13, hp, bonus); \
        break; \
    case start_time + 12: \
        push_npc(32, -10, 0, 2, tile, 14, hp, bonus); \
        push_npc(288, -10, 0, 2, tile, 14, hp, bonus); \
        break; \
    case start_time + 14: \
        npc_by_type_set_speed(10, 0, 0); \
        npc_by_type_set_speed(11, 0, 0); \
        npc_by_type_set_speed(12, 0, 0); \
        npc_by_type_set_speed(13, 0, 0); \
        npc_by_type_set_speed(14, 0, 0); \
        npc_type_shoot(12, 0, 4); \
        npc_type_shoot(13, 0, 4); \
        npc_type_shoot(11, 0, 4); \
        npc_type_shoot(10, 0, 4); \
        break; \
    case start_time + 15: \
    case start_time + 16: \
    case start_time + 17: \
    case start_time + 18: \
        npc_type_shoot(12, 0, 4); \
        npc_type_shoot(13, 0, 4); \
        npc_type_shoot(14, 0, 4); \
        npc_type_shoot(11, 0, 4); \
        npc_type_shoot(10, 0, 4); \
        break; \
    case start_time + 25: \
        npc_by_type_set_speed(10, 0, 2); \
        npc_by_type_set_speed(11, 0, 2); \
        npc_by_type_set_speed(12, 0, 2); \
        npc_by_type_set_speed(13, 0, 2); \
        npc_by_type_set_speed(14, 0, 2); \
        break;

#define triangle_non_shoot(start_time, tile, hp, bonus) \
    case start_time: \
        push_npc(160, -10, 0, 2, tile, 10, hp, bonus); \
        break; \
    case start_time + 2: \
        push_npc(128, -10, 0, 2, tile, 11, hp, bonus); \
        push_npc(192, -10, 0, 2, tile, 11, hp, bonus); \
        break; \
    case start_time + 4: \
        push_npc(96, -10, 0, 2, tile, 12, hp, bonus); \
        push_npc(224, -10, 0, 2, tile, 12, hp, bonus); \
        break; \
    case start_time + 8: \
        push_npc(64, -10, 0, 2, tile, 13, hp, bonus); \
        push_npc(256, -10, 0, 2, tile, 13, hp, bonus); \
        break; \
    case start_time + 12: \
        push_npc(32, -10, 0, 2, tile, 14, hp, bonus); \
        push_npc(288, -10, 0, 2, tile, 14, hp, bonus); \
        break; 

#define triangle_left(start_time, tile, hp, bonus) \
    case start_time: \
        push_npc(160, -10, 0, 2, tile, 10, hp, bonus); \
        break; \
    case start_time + 2: \
        push_npc(128, -10, 0, 2, tile, 11, hp, bonus); \
        break; \
    case start_time + 4: \
        push_npc(96, -10, 0, 2, tile, 12, hp, bonus); \
        break; \
    case start_time + 8: \
        push_npc(64, -10, 0, 2, tile, 13, hp, bonus); \
        break; \
    case start_time + 12: \
        push_npc(32, -10, 0, 2, tile, 14, hp, bonus); \
        break; \
    case start_time + 14: \
        npc_by_type_set_speed(10, 0, 0); \
        npc_by_type_set_speed(11, 0, 0); \
        npc_by_type_set_speed(12, 0, 0); \
        npc_by_type_set_speed(13, 0, 0); \
        npc_by_type_set_speed(14, 0, 0); \
        npc_aimed_shoot(10); \
        npc_aimed_shoot(11); \
        npc_aimed_shoot(12); \
        npc_aimed_shoot(13); \
        npc_aimed_shoot(14); \
        break; \
    case start_time + 15: \
    case start_time + 16: \
    case start_time + 17: \
    case start_time + 18: \
        npc_aimed_shoot(10); \
        npc_aimed_shoot(11); \
        npc_aimed_shoot(12); \
        npc_aimed_shoot(13); \
        npc_aimed_shoot(14); \
        break; \
    case start_time + 25: \
        npc_by_type_set_speed(10, 2, 2); \
        npc_by_type_set_speed(11, 2, 2); \
        npc_by_type_set_speed(12, 2, 2); \
        npc_by_type_set_speed(13, 2, 2); \
        npc_by_type_set_speed(14, 2, 2); \
        break;

#define triangle_right(start_time, tile, hp, bonus) \
    case start_time: \
        push_npc(160, -10, 0, 2, tile, 20, hp, bonus); \
        break; \
    case start_time + 2: \
        push_npc(188, -10, 0, 2, tile, 21, hp, bonus); \
        break; \
    case start_time + 4: \
        push_npc(220, -10, 0, 2, tile, 22, hp, bonus); \
        break; \
    case start_time + 8: \
        push_npc(252, -10, 0, 2, tile, 23, hp, bonus); \
        break; \
    case start_time + 12: \
        push_npc(284, -10, 0, 2, tile, 24, hp, bonus); \
        break; \
    case start_time + 14: \
        npc_by_type_set_speed(20, 0, 0); \
        npc_by_type_set_speed(21, 0, 0); \
        npc_by_type_set_speed(22, 0, 0); \
        npc_by_type_set_speed(23, 0, 0); \
        npc_by_type_set_speed(24, 0, 0); \
        npc_aimed_shoot(20); \
        npc_aimed_shoot(21); \
        npc_aimed_shoot(22); \
        npc_aimed_shoot(23); \
        npc_aimed_shoot(24); \
        break; \
    case start_time + 15: \
    case start_time + 16: \
    case start_time + 17: \
    case start_time + 18: \
        npc_aimed_shoot(20); \
        npc_aimed_shoot(21); \
        npc_aimed_shoot(22); \
        npc_aimed_shoot(23); \
        npc_aimed_shoot(24); \
        break; \
    case start_time + 25: \
        npc_by_type_set_speed(20, -2, 2); \
        npc_by_type_set_speed(21, -2, 2); \
        npc_by_type_set_speed(22, -2, 2); \
        npc_by_type_set_speed(23, -2, 2); \
        npc_by_type_set_speed(24, -2, 2); \
        break;

#define droped_enemy(start_time, x, tile, hp) \
    case start_time: \
        push_npc(x, -10, 0, 4, tile, 1, hp, 0); \
        push_npc(x + 96, -10, 0, 4, tile, 1, hp, 0); \
        break;

#define firing_ice(start_time) \
    case start_time: \
        push_npc(32, 32, 0 ,0, SHARP_ICE, 50, 50, BONUS_CARD); \
        push_npc(288, 32, 0 ,0, SHARP_ICE, 50, 50, HEALTH_CARD); \
        push_npc(32, 120, 0 ,0, SHARP_ICE, 50, 50, HEALTH_CARD); \
        push_npc(288, 120, 0 ,0, SHARP_ICE, 50, 50, BONUS_CARD); \
        break; \
    case start_time + 5: \
    case start_time + 15: \
    case start_time + 25: \
    case start_time + 35: \
    case start_time + 45: \
    case start_time + 55: \
    case start_time + 65: \
    case start_time + 75: \
    case start_time + 80: \
        npc_aimed_shoot(50); \
        break; \
    case start_time + 85: \
        npc_by_type_set_speed(50, 0, 3); \
        break;

#define mid_boss1(start_time, tile, hp) \
    case start_time: \
        push_npc(160, -32, 0, 5, tile, 200, hp, 0); \
        break; \
    case start_time + 3: \
        npc_by_type_set_speed(200, 2, 0); \
        scroll_speed = 0; \
        break; \
    just_star(start_time + 5, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 6: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 7, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 8: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 9, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 10: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 11, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 12: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    case start_time + 13: \
        npc_by_type_set_speed(200, -2, 0); \
        break; \
        just_star(start_time + 15, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 16: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 19, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 20: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 21, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 22: \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 23, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 24: \
        if (find_npc_by_type(200)) level_loop = start_time + 2; \
        break; \
    case start_time + 25: \
        scroll_speed = 1; \
        for (push_counter = 0;push_counter < 5;push_counter ++) \
            push_bonus((push_counter % 2) == 1 ? BONUS_CARD : HEALTH_CARD, 160, 70, 3 - (push_counter * 2), 3); \
        break;

#define mid_boss2(start_time, tile, hp) \
    case start_time: \
        push_npc(160, 32, 2, 0, tile, 200, hp, HEALTH_CARD); \
        scroll_speed = 0; \
        break; \
    case start_time + 2: \
    case start_time + 4: \
    case start_time + 7: \
    case start_time + 9: \
        npc_aimed_shoot(200); \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 10, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 11: \
        npc_by_type_set_speed(200, -2, 0); \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    case start_time + 12: \
    case start_time + 14: \
    case start_time + 18: \
        npc_aimed_shoot(200); \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    just_star(start_time + 22, find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); \
    case start_time + 23: \
        npc_by_type_set_speed(200, 2, 0); \
        level_loop = start_time; \
        if (find_npc_by_type(200) == 0) level_loop = start_time + 24; \
        break; \
    case start_time + 25: \
        scroll_speed = 1; \
        push_bonus(HEALTH_CARD, 160, 120, 0, -5); \
        push_bonus(BONUS_CARD, 170, 110, 0, -5); \
        push_bonus(HEALTH_CARD, 150, 150, 0, -5); \
        push_bonus(BONUS_CARD, 130, 100, 0, -5); \
        push_bonus(BONUS_CARD, 140, 110, 0, -5); \
        push_bonus(HEALTH_CARD, 150, 140, 0, -5); \
        push_bonus(BONUS_CARD, 130, 120, 0, -5); \
        break;

#define boss_attack_drop_npc(start_time, tile) \
        droped_enemy(start_time    , 20,  tile, 1); \
        droped_enemy(start_time + 1, 50,  tile, 1); \
        droped_enemy(start_time + 2, 10,  tile, 1); \
        droped_enemy(start_time + 3, 80,  tile, 1); \
        droped_enemy(start_time + 4, 160, tile, 1); \
        droped_enemy(start_time + 5, 220, tile, 1);
