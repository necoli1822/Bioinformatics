from time import clock
import time
import os
import multiprocessing as mp
import numpy as np
import Util
import LogicPrep
import Logic

############### start to set env ###############

WORK_DIR = os.getcwd() + "/"
NGS_read = "input/NGS_read_test.txt"

# NGS_read = "input/NGS_read.txt"

REF_SEQ = "input/Reference_test.txt"

# REF_SEQ = "input/Reference.txt"

PAIRWISE2_OPT = []
MULTI_CNT = 10

# MULTI_CNT = 36

TOP_N = 5
IDX = 0

############### end setting env ################


def multi_processing():
    util = Util.Utils()
    logic = Logic.Logics()
    ngs_read = util.read_tb_txt(WORK_DIR + NGS_read)
    ref_seq = util.read_tb_txt(WORK_DIR + REF_SEQ)
    # multiprocessing 시 아주 큰 데이터(split될것)과 작은 데이터'들'로 나눈다
    logic_prep = LogicPrep.LogicPreps(ref_seq)  # 상대적은로 작은 data(ref_seq)는 전역변수나, 생성자로 넘겨준다.
    # multiprocessing 시 상대적으로 아주 큰 데이터(ngs_read)는 multiprocessing 쓸 cpu 만큼 나눠준다. : MULTI_CNT
    splited_ngs_read = np.array_split(ngs_read, MULTI_CNT)
    print("total cpu_count : " + str(mp.cpu_count()))
    print("will use : " + str(MULTI_CNT))
    pool = mp.Pool(processes=MULTI_CNT)


    # multiprocessing의 결과는 list 형태로 반환된다. list의 element는 get_pairwise2_needle_dict_by_res_seq의 반환형태
    pool_list = pool.map(logic_prep.get_pairwise2_needle_dict_by_res_seq, splited_ngs_read)

    # multiprocessing 결과 list를 합쳐 준다
    merge_dict = logic_prep.merge_multi_dict(pool_list)
    sorted_dict = logic.sort_dict_top_n_by_idx_ele(merge_dict, IDX, TOP_N)
    util.make_excel_mutil_processing(WORK_DIR + "output/multi_p_result_", sorted_dict)

if __name__ == '__main__':
    start_time = clock()
    # start_time = time.clock_gettime(1)
    print("start >>>>>>>>>>>>>>>>>>")
    multi_processing()
    print("::::::::::: %.2f seconds ::::::::::::::" % (clock() - start_time))
    # print("::::::::::: %.2f seconds ::::::::::::::" % (time.clock_gettime(1) - start_time))

#[출처] multiprocessing|작성자 e뻔한세상
