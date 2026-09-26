from src.api.items import Item, create_item, get_item


def test_create_and_get():
    item = create_item(Item(id=1, name="first"))
    assert get_item(1) == item


def test_duplicate_id_raises():
    create_item(Item(id=2, name="dup"))
    try:
        create_item(Item(id=2, name="dup"))
    except ValueError as exc:
        assert "已存在" in str(exc)
    else:
        raise AssertionError("重复 id 应当抛错")
