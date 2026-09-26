"""示例：按 core/20 代码风格写的极简 items 接口。"""
from pydantic import BaseModel


class Item(BaseModel):
    id: int
    name: str


_ITEMS: dict[int, Item] = {}


def create_item(item: Item) -> Item:
    # 提前返回：重复 id 直接报错，说明「什么失败 + 怎么办」
    if item.id in _ITEMS:
        raise ValueError(f"item id={item.id} 已存在，请先 delete 或换一个 id")
    _ITEMS[item.id] = item
    return item


def get_item(item_id: int) -> Item | None:
    return _ITEMS.get(item_id)
