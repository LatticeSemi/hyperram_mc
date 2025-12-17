
#ifndef REG_TEST_H_
#define REG_TEST_H_

#define reg_test_assert(cond) if (!(cond)) { printf("%s:%d\n",__FILE__,__LINE__);while(1); }

uint8_t access_detect(uint32_t reg_addr,  uint32_t offset, uint32_t mask, char *inst_name, char *reg_name);
uint8_t mem_access_test(void);
#endif
