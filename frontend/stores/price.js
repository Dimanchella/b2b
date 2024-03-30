import {defineStore} from "pinia";

export const usePriceStore = defineStore("priceStore", () => {
    const products = ref([])
    const groups = ref([])
    const perPage = ref(1)
    const numPages = ref(1)
    const currentPage = ref(1)
    const count = ref(0)
    const search = ref(null)
    const price_min = ref(null)
    const price_max = ref(null)
    const page = ref(1)
    const group = ref(null)

    const getPriceList = async (is_root) => {
        const {data} = await useFetch(`/api/v1/prices`, {
            method: "POST",
            body: {
                payload: {
                    search: search.value,
                    price_min: price_min.value,
                    price_max: price_max.value,
                    page: page.value,
                    group: group.value
                }
            }
        })

        //console.log('getPriceList.is_root: ', is_root)
        if (is_root === 1) {
            products.value = [];
        }
        if (data.value?.results) {
            count.value = data.value?.results.count
            numPages.value = data.value?.results.num_pages
            perPage.value = data.value?.results.per_page
            currentPage.value = data.value?.results.current_page
            products.value = data.value?.results.results

            // console.log("Old method:", {
            //     count: count.value,
            //     numPages: numPages.value,
            //     perPage: perPage.value,
            //     currentPage: currentPage.value,
            //     // products: products.value
            // })
            //
            // const per_page = data.value?.results.per_page;
            // const items = data.value?.results.results;
            // //console.log('getPriceList.items: ', items);
            // if (is_root === undefined)
            //     products.value = items;
            // else if (items.length > 0)
            //     products.value.push(... items);
            // const size = products.value.length;
            // const num_pages = Math.floor(size / per_page);
            //
            // perPage.value = per_page;
            // count.value = size;
            // numPages.value = num_pages;
            // currentPage.value = data.value?.results.current_page;
            //
            // console.log("New method:", {
            //     count: count.value,
            //     numPages: numPages.value,
            //     perPage: perPage.value,
            //     currentPage: currentPage.value,
            //     // products: products.value
            // })

            //data.value?.results.per_page = per_page;
            //data.value?.results.num_pages = num_pages;

            //await changeSelectedGroupTitle();

            //console.log('getPriceList.products: ', products.value, size, per_page, num_pages);
        } else if (data.value?.error) {
            console.log("getPriceList", data.value?.error)
            // TODO сделать вывод ошибок
        }
    }

    const getGroupTree = async () => {
        const {data} = await useFetch(`/api/v1/group_tree`)
        groups.value = data.value?.results
    }

    const getPriceDetail = async (id) => {
        const {data} = await useFetch('/api/v1/price_detail', {
            method: 'GET',
            query: {
                id: id,
            }
        })

        if (data.value?.results) {
            return data.value.results
        } else if (data.value?.error) {
            console.log("getPriceDetail", data.value?.error)
            // TODO сделать вывод ошибок
        }
    }

    const resetPagination = () => {
        page.value = 1
    }

    return {
        products,
        groups,
        perPage,
        numPages,
        currentPage,
        count,
        search,
        price_min,
        price_max,
        page,
        group,
        getPriceList,
        getGroupTree,
        getPriceDetail,
        resetPagination
    }
})